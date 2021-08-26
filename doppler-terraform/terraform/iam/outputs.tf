# vim: ts=4:sw=4:et:ft=hcl

output "siab_servers_role_name" {
  value = aws_iam_role.siab_servers_role.name
}
