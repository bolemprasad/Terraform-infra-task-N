output "key_name" {
  description = "Key pair name created in AWS"
  value       = aws_key_pair.this.key_name
}
