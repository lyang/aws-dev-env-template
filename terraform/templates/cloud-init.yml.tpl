#cloud-config
system_info:
  default_user:
    name: ${ec2-user}

package_update: true
package_upgrade: true