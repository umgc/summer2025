output "route53_zone_id" {
  value = aws_route53_zone.this.zone_id
}

// Comment out for now because value was causing syntax error
/*output "ses_domain_identity_arn" {
  value = aws_ses_domain_identity.this.domain.arn
}
*/

output "ses_verification_token" {
  value = aws_ses_domain_identity.this.verification_token
}

output "ses_dkim_tokens" {
  value = aws_ses_domain_dkim.this.dkim_tokens
}