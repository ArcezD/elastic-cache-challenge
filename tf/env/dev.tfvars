ec2_key_name = "<<YOUR_OWN_KEY_PAIR>>"
ec2_instance_name = "A Cloud Guru App Server"

rds_instance_identifier  = "acloudguruchallenge"
rds_instance_db_name     = "challenge"
rds_instance_db_username = "cloudguru"

redis_cluster_name = "redis-cloudguru"

sql_initial_script_url = "https://raw.githubusercontent.com/ArcezD/elastic-cache-challenge/master/install.sql"

tags = {
  Project = "A Cloud Guru Challenge June 21"
  TerraformRepo = "https://github.com/ArcezD/elastic-cache-challenge"
}
