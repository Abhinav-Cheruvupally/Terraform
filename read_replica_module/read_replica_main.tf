resource "aws_db_instance" "read_replica" {
    name = var.name
    instance_class = var.instance_class
    identifier_prefix = var.env
    replicate_source_db = var.replicate_source_db
    parameter_group_name = var.parameter_group_name
    storage_encrypted = true
    multi_az = false
    availability_zone=var.availability_zone
    kms_key_id = var.kms_key_id
    deletion_protection = var.deletion_protection
    skip_final_snapshot = true
    final_snapshot_identifier = null
    vpc_security_group_ids = var.security_groups
}

