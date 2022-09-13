###### opt/tomcat altına zip dosyasını indirip tüm ayarlamaları yaparak start verir.

TOMCAT_URL="https://kozyatagi.mirror.guzel.net.tr/apache/tomcat/tomcat-9/v9.0.54/bin/apache-tomcat-9.0.54-deployer.tar.gz"

if [ ! -d "/opt/tomcat" ]
then
    echo 'Indiriliyor tomcat-9.0...'
if [ ! -f /etc/apache-tomcat-9*tar.gz ]
 then
    curl -O $TOMCAT_URL
	echo 'Indirme Tamamlandı'
fi

   
	sudo yum install tar -y
   
    sudo mkdir -p '/opt/tomcat'
    echo 'Tomcat Klasoru Olusturuldu'
   
    sudo tar xzf apache-tomcat-9*tar.gz -C "/opt/tomcat" --strip-components=1
    echo 'Tar.gz Klasorden cikartildı'

    sudo groupadd tomcat
	echo 'Tomcat Kullanıcısı Olusturuldu'

    useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

    echo 'Klasor Yetkisi Veriliyor'
    
    cd "/opt/"
    sudo chown -hR tomcat:tomcat tomcat
    sudo chmod -R 777 tomcat
    
    sudo chmod -R g+w conf
          
          #klasorlere yetki verilimi
    sudo chown -R tomcat webapps/ work/ temp/ logs/
  
    echo 'Tomcat Service Ayarlari'
    sudo touch tomcat.service
    sudo chmod 777 tomcat.service 
    echo "[Unit]" > tomcat.service
    echo "Description=Apache Tomcat Web Application Container" >> tomcat.service
    echo "After=network.target" >> tomcat.service

    echo "[Service]" >> tomcat.service
    echo "Type=forking" >> tomcat.service

    echo "Environment=JAVA_HOME=/usr/lib/jvm/jre" >> tomcat.service
    echo "Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid" >> tomcat.service
    echo "Environment=CATALINA_HOME=/opt/tomcat" >> tomcat.service
    echo "Environment=CATALINA_BASE=/opt/tomcat" >> tomcat.service
    echo "Environment=CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC" >> tomcat.service
    echo "Environment=JAVA_OPTS=-Djava.security.egd=file:///dev/urandom" >> tomcat.service
	echo 'Environment="UMask=0002"' >> tomcat.service

    echo "ExecStart=/opt/tomcat/bin/startup.sh" >> tomcat.service
    echo "ExecStop=/opt/tomcat/bin/shutdown.sh" >> tomcat.service

    echo "User=tomcat" >> tomcat.service
    echo "Group=tomcat" >> tomcat.service

    echo "RestartSec=10" >> tomcat.service
    echo "Restart=always" >> tomcat.service

    echo "[Install]" >> tomcat.service
    echo "WantedBy=multi-user.target" >> tomcat.service

    sudo mv tomcat.service /etc/systemd/system/tomcat.service
    sudo chmod 755 /etc/systemd/system/tomcat.service


	echo 'JAVA_OPTS="$JAVA_OPTS -Dspring.profiles.active=prod"' >> setenv.sh
	
	sudo mv setenv.sh /opt/tomcat/bin/setenv.sh

#   buradaki ' >>tomcat-users.xml yazması boşluk koydurma amacı ile yapılmıştır.

    echo 'Tomcat Kullanıcı Ayarları'
	
	sudo touch tomcat-users.xml
	
	echo '<?xml version="1.0" encoding="UTF-8"?>
	' >> tomcat-users.xml
	
	echo '<tomcat-users xmlns="http://tomcat.apache.org/xml"' >> tomcat-users.xml
	echo '               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' >> tomcat-users.xml
	echo '               xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"' >> tomcat-users.xml
	echo '               version="1.0">
	' >> tomcat-users.xml
	
	echo '<role rolename="admin-gui"/>' >> tomcat-users.xml
	echo '<role rolename="manager-gui"/>' >> tomcat-users.xml
	echo '<user username="admin" password="admin" roles="admin-gui,manager-gui,manager-script"/>
	' >> tomcat-users.xml
	echo '</tomcat-users>' >> tomcat-users.xml
	
 	sudo mv tomcat-users.xml /opt/tomcat/conf/tomcat-users.xml


    echo 'Host Manager ve Uzak Erisim Ayarları'
	
	sudo touch context.xml
	
	echo '<?xml version="1.0" encoding="UTF-8"?>
	' >> context.xml
	
	echo '<Context antiResourceLocking="false" privileged="true" >' >> context.xml
	echo ' <Valve className="org.apache.catalina.valves.RemoteAddrValve" allow="10\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />' >> context.xml
	echo '</Context>' >> context.xml
	
	sudo cp context.xml /opt/tomcat/webapps/manager/META-INF/context.xml
	sudo cp context.xml /opt/tomcat/webapps/host-manager/META-INF/context.xml
	
	sudo rm -rf context.xml
	

    sudo systemctl daemon-reload
    sudo systemctl enable tomcat
    sudo firewall-cmd --zone=public --permanent --add-port=8080/tcp
    sudo firewall-cmd --reload
    sudo systemctl start tomcat
	
	exit
	
  
   
	
else
	
	read -p "Tomcat Zaten Yüklü Taşıma İşlemi Yapılsın Mı ? [Y/n] :" 
	if [[ ! $REPLY =~ ^[Yy]$ ]]
	then
		exit
	 else
		systemctl stop tomcat
		sudo mkdir Tomcat-Old
		  echo "Tomcat-Old Klasörü Oluşturuldu."
		mv tomcat/* Tomcat-Old/
		  echo "Tomcat Klasörü Tomcat-Old Klasörüne Taşındı"
		rm -rf tomcat
		  echo "Tomcat Taşınıp eski klasör silindi."
	 exit 
	fi
	
exit
fi
