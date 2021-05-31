output "db_endpoint" {
  value = aws_docdb_cluster.docdb.endpoint
}

output "db_user" {
  value = aws_docdb_cluster.docdb.master_username
}

output "db_pass" {
  value = aws_docdb_cluster.docdb.master_password
  sensitive = true
}