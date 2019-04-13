This script package can complete the CST8213 final SBA test automatically.
However, if you don't know what it is doing, this package will not help you but mess up your test.
The test need two VMs, one for server, the other for client to test the services.

Tasks are as follows:
1. Set up two CentOS 7 64-bit VM. Each of them has two NICs, one for internal Red network (Bridged), one for internet Blue network (NAT).
2. Assign IP address for both of them, Red network nic has two IP addresses (aliase).
3. Creat test user "last" with password "exam".
4. Setup SSH service, enable publickey and password authentication, as well as root login.
5. Setup DNS for all different services domains. Server is the NS1, Client is the NS2 server.
6. Setup DNS zone of snow.lab, with client as the slave server. Creat MX record and reverse lookup zone.
7. Setup HTTP service for default snow.lab, www.white.lab, www1.white.lab, www2.white.lab, and HTTPS service for secure.white.lab. All have different index.html page.
8. Setup Postfix mail service for bashful.lab and sleppy.lab, so that server can receive email for user last@bashful.lab and alias labtest@sleppy.lab.
9. Setup LDAP service, create entries for people ou, R.H. user, www.grumpy.lab host. The client can use ldap as the DNS records, getent can lookup www.grump.lab.
10. Setup SAMBA service, share HOME directories for users and Public share.
11. Setup NFS service, share a folder and mount it to the client.
12. Setup Postgresql service, initialize the database.

Installation steps:
1. Install two CentOS 7 64-bit VMs. Create two NIC for both of them.
2. Connect to the Internet using the NAT NIC.
3. Copy the sba folder to server's root home directory.
4. Copy the sbac folder to client's root home directory.
5. Execute script.sh in the shell for both of them.
6. Say yes to the yum.
