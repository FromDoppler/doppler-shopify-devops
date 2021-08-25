import os
import boto3
import logging
from helpers.table import print_table
from operator import itemgetter

# Get needed environment variables (account and region)
MAIN_ACCOUNT = os.getenv('AWS_ACCOUNT')
MAIN_REGION = os.environ.get('AWS_REGION')

AVAILABLE_REGIONS = [ MAIN_REGION ]
AVAILABLE_ACCOUNTS = { '{0}'.format(MAIN_ACCOUNT): {'country': 'usa',  'default_region': 'us-east-2'} }  # USA


class bcolors:
    HEADER = '\033[34m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


class AWSHandler:

    def __init__(self):
        self.session = None
        self.logger = logging.getLogger('root')

    def connect(self, account):
        self.logger.debug("Connection to account {}".format(account))
        session = boto3.Session()
        client = session.client('sts')
        response = client.assume_role(RoleArn='arn:aws:iam::{}:role/automation_role'.format(account), RoleSessionName='Test')
        self.session = boto3.Session(aws_access_key_id=response['Credentials']['AccessKeyId'],
                                     aws_secret_access_key=response['Credentials']['SecretAccessKey'],
                                     aws_session_token=response['Credentials']['SessionToken'])

    def list(self, role, region):
        if not self.session:
            self.connect(MAIN_ACCOUNT)
        ec2 = self.session.resource('ec2', region_name=region)
        return list(ec2.images.filter(
            Owners=[str(MAIN_ACCOUNT)],
            Filters=[{'Name': 'tag:Role', 'Values': [role]}]).all())

    def get_image(self, ami_id, region):
        if not self.session:
            self.connect(MAIN_ACCOUNT)
        ami = self.session.resource('ec2', region_name=region).Image(ami_id)
        return ami

    def get_ami_by_uuid(self, uuid, region):
        if not self.session:
            self.connect(MAIN_ACCOUNT)
        ec2 = self.session.resource('ec2', region_name=region)
        self.logger.debug('Looking for image in region {} with uuid: {}'.format(region, uuid))
        return list(ec2.images.filter(
            Owners=[str(MAIN_ACCOUNT)],
            Filters=[{'Name': 'tag:BuildUUID', 'Values': [uuid]}]).all())[0]

    def get_most_recent_approved_ami(self, environment, role, region):
        if not self.session:
            self.connect(MAIN_ACCOUNT)
        ec2 = self.session.resource('ec2', region_name=region)
        image_list = list(ec2.images.filter(
            Owners=[str(MAIN_ACCOUNT)],
            Filters=[{'Name': 'tag:Role', 'Values': [role]}, {'Name': 'tag:Approved_for', 'Values': ["*{}*".format(environment)]}]).all())
        d = []
        for i in image_list:
            d.append((i.image_id, self.get_tag_value(i.tags, 'BuildDate')))
        return max(d, key=itemgetter(1))[0]

    @staticmethod
    def get_tag_value(tag_list, key):
        x = [tag['Value'] for tag in tag_list if tag['Key'] == key]
        return ''.join(x)

    @staticmethod
    def get_tag_pos(tag_list, key):
        x = [pos for pos, tag in enumerate(tag_list) if tag['Key'] == key]
        return x.pop() if x else None

    def print_image_list(self, arguments):
        role = arguments.role
        headers = [
            ('BuildUUID', 'UUID'),
            ('Name', 'Name'),
            ('us-east-2', 'us-east-2'),
            ('Approved_for', 'Approved'),
            ('BuildDate', 'Date'),
            ('GitCommit', 'Commit')
        ]
        l = []
        for region in AVAILABLE_REGIONS:
            # get images in region
            ami_list = self.list(role, region)
            for ami in ami_list:
                pos = [pos for pos, d in enumerate(l) if d['BuildUUID'] == self.get_tag_value(ami.tags, 'BuildUUID')]
                if pos:
                    l[pos[0]][region] = ami.image_id
                else:
                    d = {'BuildUUID': self.get_tag_value(ami.tags, 'BuildUUID'),
                         'Name': self.get_tag_value(ami.tags, 'Name'),
                         region: ami.image_id,
                         'Approved_for': self.get_tag_value(ami.tags, 'Approved_for'),
                         'BuildDate': self.get_tag_value(ami.tags, 'BuildDate'),
                         'GitCommit': self.get_tag_value(ami.tags, 'GitCommit')
                         }
                    for missing_region in list(set(AVAILABLE_REGIONS) - {region}):
                        d[missing_region] = ''
                    l.append(d)

        # Order by the datetime field
        data = sorted(l, key=itemgetter('BuildDate'), reverse=True)
        print_table(data, headers)
        print("Total: {} row/s".format(len(data)))

    def ami_is_clean(self, ami_tags):
        if 'dirty' in self.get_tag_value(ami_tags, 'GitCommit'):
            return False
        return True

    def promote(self, arguments):
        uuid = arguments.uuid
        environment = arguments.environment
        ami = self.get_ami_by_uuid(uuid, MAIN_REGION)
        # Get tags from original AMI
        tags = ami.tags
        if arguments.force or self.ami_is_clean(tags):
            # get tag position
            pos = self.get_tag_pos(tags, 'Approved_for')
            # if tag existed, add the value of $environment
            if pos:
                approved_for = tags.pop(pos)
                approved_for_values = filter(None, approved_for['Value'].split('|'))
                if environment not in approved_for_values:
                    approved_for_values.append(environment)
                approved_for['Value'] = '|'.join(sorted(approved_for_values))
                tags.append(approved_for)
            else:
                tags.append({'Key': 'Approved_for', 'Value': environment})
            self.update_tags(tags)
        else:
            self.logger.error("Trying to promote ami which was created from a dirty commit. Try with -f if you are really sure of what you are doing.")

    def demote(self, arguments):
        uuid = arguments.uuid
        environment = arguments.environment
        ami = self.get_ami_by_uuid(uuid, MAIN_REGION)
        # Get tags from original AMI
        tags = ami.tags
        # get tag position
        pos = self.get_tag_pos(tags, 'Approved_for')
        # if tag existed, remove the value of $environment
        if pos:
            approved_for = tags.pop(pos)
            approved_for_values = filter(None, approved_for['Value'].split('|'))
            if environment in approved_for_values:
                approved_for_values.remove(environment)
            approved_for['Value'] = '|'.join(sorted(approved_for_values))
            tags.append(approved_for)
        else:
            tags.append({'Key': 'Approved_for', 'Value': ''})
        self.update_tags(tags)

    def update_tags(self, tags):
        # get UUID from original tags
        uuid = self.get_tag_value(tags, 'BuildUUID')
        # get image id for each region
        ami_per_region = {}
        for region in AVAILABLE_REGIONS:
            ami = self.get_ami_by_uuid(uuid, region)
            ami_per_region[region] = ami.image_id
        # go through every account
        for account in AVAILABLE_ACCOUNTS.keys():
            # for each region, tag the correspondent ami
            for region, ami_id in ami_per_region.items():
                self.connect(account)
                ami = self.get_image(ami_id, region)
                self.logger.info('Updating tags on {}:{}'.format(account, region))
                ami.create_tags(Tags=tags)

    def get_env_overview(self, arguments):
        country = arguments.country_code
        environment = arguments.environment
        project = arguments.project
        account, account_info = [(i, v) for i, v in AVAILABLE_ACCOUNTS.items() if v['country'] == country][0]
        data = []
        headers = [
            ('asg_name', '{}ASG Name{}'.format(bcolors.HEADER, bcolors.ENDC)),
            ('lc_name', '{}Launch Configuration{}'.format(bcolors.HEADER, bcolors.ENDC)),
            ('lc_image', '{}AMI of LC{}'.format(bcolors.HEADER, bcolors.ENDC)),
            ('last_ami', '{}Latest Approved{}'.format(bcolors.HEADER, bcolors.ENDC)),
            ('sync', '{}Sync{}'.format(bcolors.HEADER, bcolors.ENDC))
        ]

        self.connect(account)
        ec2 = self.session.resource('ec2', region_name=account_info['default_region'])
        autoscaling = self.session.client('autoscaling', region_name=account_info['default_region'])
        response = autoscaling.describe_auto_scaling_groups(MaxRecords=100)
        add_diff_header = False
        # for each ASG
        for asg in response['AutoScalingGroups']:
            # If it matches the filters
            if next((i for i in asg['Tags'] if i['Key'] == 'Environment' and i['Value'] == environment), None) \
                    and next((i for i in asg['Tags'] if i['Key'] == 'Project' and i['Value'] == project), None):
                lc = autoscaling.describe_launch_configurations(LaunchConfigurationNames=[asg['LaunchConfigurationName']])['LaunchConfigurations'][0]
                last_ami_for_role = self.get_most_recent_approved_ami(environment, self.get_tag_value(asg['Tags'], 'Role'), account_info['default_region'])
                number_of_instances = 0
                synced_instances = 0
                diff_amis = []
                # Get the info about the instances
                for instance in asg['Instances']:
                    number_of_instances += 1
                    ami = ec2.Instance(instance['InstanceId']).image_id
                    if ami == lc['ImageId']:
                        synced_instances += 1
                    else:
                        add_diff_header = True
                        diff_amis.append(ami)
                data.append({
                    'asg_name': asg['AutoScalingGroupName'],
                    'lc_name': lc['LaunchConfigurationName'],
                    'lc_image': '{}{}{}'.format(bcolors.OKGREEN, lc['ImageId'], bcolors.ENDC) if lc['ImageId'] == last_ami_for_role else "{}{}{}".format(bcolors.FAIL, lc['ImageId'], bcolors.ENDC),
                    'sync': "{}{}/{}{}".format(bcolors.OKGREEN, synced_instances, number_of_instances, bcolors.ENDC) if synced_instances == number_of_instances else "{}{}/{}{}".format(bcolors.FAIL, synced_instances, number_of_instances, bcolors.ENDC),
                    'diff': ' '.join(diff_amis),
                    'last_ami': last_ami_for_role
                })
        if add_diff_header:
            headers.append(('diff', '{}Different Images{}'.format(bcolors.HEADER, bcolors.ENDC)))
        print_table(data, headers)
