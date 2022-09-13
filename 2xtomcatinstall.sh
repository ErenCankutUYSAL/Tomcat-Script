###### 2 adet tomcat kurarak isimlerini tomcat1 tomcat2 yapar ve kurulum sonrası firewall ayarları yapar ve tomcat servicede ayarlamaları yaparak farklı portlardan ayağa kaldırıp çalışır duruma getirilir.

sed -i 's/\r$//' testtomcat.sh

TOMCAT_URL="https://ftp.itu.edu.tr/Mirror/Apache/tomcat/tomcat-9/v9.0.41/bin/apache-tomcat-9.0.41.tar.gz"

#ekrana girilen değere göre tomcat klasörü açsın 10 tane tomcat kursun.

# ekrana girilen değere göre portları ayarlasın değer 5 ise 8080 + 1 +2 +3 +4 +5 olarak devam etsin

# ekrana girilen degere göre tomcat1.service gibi tek tek artırsın 'tomcat.service' den başlayacak

if [ ! -d "/opt/tomcat" ]
then


    echo 'Indiriliyor tomcat-9.0...'

if [ ! -f /opt/apache-tomcat-9*tar.gz ]
 then
    curl -O $TOMCAT_URL
	echo 'Indirme Tamamlandı'
fi

   
	sudo yum install tar -y
   
    sudo mkdir -p '/opt/tomcat'
    sudo mkdir -p '/opt/tomcat1'
    echo 'Tomcat Klasoru Olusturuldu'
   
    sudo tar xzf apache-tomcat-9*tar.gz -C "/opt/tomcat" --strip-components=1
    sudo tar xzf apache-tomcat-9*tar.gz -C "/opt/tomcat1" --strip-components=1
    echo 'Tar.gz Klasorden cikartildı'

    sudo groupadd tomcat
    sudo groupadd tomcat1
	echo 'Tomcat Kullanıcısı Olusturuldu'

    useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
    useradd -s /bin/false -g tomcat1 -d /opt/tomcat1 tomcat1

    echo 'Klasor Yetkisi Veriliyor'
    
    cd "/opt/"
    sudo chown -hR tomcat:tomcat tomcat
    sudo chown -hR tomcat1:tomcat1 tomcat1
    sudo chmod -R 777 tomcat
    sudo chmod -R 777 tomcat1
    
    sudo chmod -R g+w conf
          
          #klasorlere yetki verilimi
    #sudo chown -R tomcat webapps/ work/ temp/ logs/
  
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

    echo "ExecStart=/opt/tomcat/bin/startup.sh" >> tomcat.service
    echo "ExecStop=/opt/tomcat/bin/shutdown.sh" >> tomcat.service

    echo "User=tomcat" >> tomcat.service
    echo "Group=tomcat" >> tomcat.service
    echo "UMask=0007" >> tomcat.service
    echo "RestartSec=10" >> tomcat.service
    echo "Restart=always" >> tomcat.service

    echo "[Install]" >> tomcat.service
    echo "WantedBy=multi-user.target" >> tomcat.service
	
	#tomcat1.servis
	echo 'Tomcat Service Ayarlari'
    sudo touch tomcat1.service
    sudo chmod 777 tomcat1.service 
    echo "[Unit]" > tomcat1.service
    echo "Description=Apache Tomcat Web Application Container" >> tomcat1.service
    echo "After=network.target" >> tomcat1.service

    echo "[Service]" >> tomcat1.service
    echo "Type=forking" >> tomcat1.service

    echo "Environment=JAVA_HOME=/usr/lib/jvm/jre" >> tomcat1.service
    echo "Environment=CATALINA_PID=/opt/tomcat1/temp/tomcat.pid" >> tomcat1.service
    echo "Environment=CATALINA_HOME=/opt/tomcat1" >> tomcat1.service
    echo "Environment=CATALINA_BASE=/opt/tomcat1" >> tomcat1.service
    echo "Environment=CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC" >> tomcat1.service
    echo "Environment=JAVA_OPTS=-Djava.security.egd=file:///dev/urandom" >> tomcat1.service

    echo "ExecStart=/opt/tomcat1/bin/startup.sh" >> tomcat1.service
    echo "ExecStop=/opt/tomcat1/bin/shutdown.sh" >> tomcat.service

    echo "User=tomcat1" >> tomcat1.service
    echo "Group=tomcat1" >> tomcat1.service
    echo "UMask=0007" >> tomcat1.service
    echo "RestartSec=10" >> tomcat1.service
    echo "Restart=always" >> tomcat1.service

    echo "[Install]" >> tomcat1.service
    echo "WantedBy=multi-user.target" >> tomcat1.service

    sudo mv tomcat.service /etc/systemd/system/tomcat.service
    sudo mv tomcat1.service /etc/systemd/system/tomcat1.service
    sudo chmod 755 /etc/systemd/system/tomcat.service
    sudo chmod 755 /etc/systemd/system/tomcat1.service


#server.xml port ve server port ayarlarını yapıyoruz ekranın tamamını aldım cünkü içerisinde pasif olup işe yarayan bilgiler mevcut.

	echo '<?xml version="1.0" encoding="UTF-8"?>
<!--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
<!-- Note:  A "Server" is not itself a "Container", so you may not
     define subcomponents such as "Valves" at this level.
     Documentation at /docs/config/server.html
 -->
<Server port="8006" shutdown="SHUTDOWN">
  <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
  <!-- Security listener. Documentation at /docs/config/listeners.html
  <Listener className="org.apache.catalina.security.SecurityListener" />
  -->
  <!--APR library loader. Documentation at /docs/apr.html -->
  <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
  <!-- Prevent memory leaks due to use of particular java/javax APIs-->
  <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
  <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
  <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />

  <!-- Global JNDI resources
       Documentation at /docs/jndi-resources-howto.html
  -->
  <GlobalNamingResources>
    <!-- Editable user database that can also be used by
         UserDatabaseRealm to authenticate users
    -->
    <Resource name="UserDatabase" auth="Container"
              type="org.apache.catalina.UserDatabase"
              description="User database that can be updated and saved"
              factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
              pathname="conf/tomcat-users.xml" />
  </GlobalNamingResources>

  <!-- A "Service" is a collection of one or more "Connectors" that share
       a single "Container" Note:  A "Service" is not itself a "Container",
       so you may not define subcomponents such as "Valves" at this level.
       Documentation at /docs/config/service.html
   -->
  <Service name="Catalina">

    <!--The connectors can use a shared executor, you can define one or more named thread pools-->
    <!--
    <Executor name="tomcatThreadPool" namePrefix="catalina-exec-"
        maxThreads="150" minSpareThreads="4"/>
    -->


    <!-- A "Connector" represents an endpoint by which requests are received
         and responses are returned. Documentation at :
         Java HTTP Connector: /docs/config/http.html
         Java AJP  Connector: /docs/config/ajp.html
         APR (HTTP/AJP) Connector: /docs/apr.html
         Define a non-SSL/TLS HTTP/1.1 Connector on port 8080
    -->
    <Connector port="8081" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />
    <!-- A "Connector" using the shared thread pool-->
    <!--
    <Connector executor="tomcatThreadPool"
               port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />
    -->
    <!-- Define an SSL/TLS HTTP/1.1 Connector on port 8443
         This connector uses the NIO implementation. The default
         SSLImplementation will depend on the presence of the APR/native
         library and the useOpenSSL attribute of the
         AprLifecycleListener.
         Either JSSE or OpenSSL style configuration may be used regardless of
         the SSLImplementation selected. JSSE style configuration is used below.
    -->
    <!--
    <Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol"
               maxThreads="150" SSLEnabled="true">
        <SSLHostConfig>
            <Certificate certificateKeystoreFile="conf/localhost-rsa.jks"
                         type="RSA" />
        </SSLHostConfig>
    </Connector>
    -->
    <!-- Define an SSL/TLS HTTP/1.1 Connector on port 8443 with HTTP/2
         This connector uses the APR/native implementation which always uses
         OpenSSL for TLS.
         Either JSSE or OpenSSL style configuration may be used. OpenSSL style
         configuration is used below.
    -->
    <!--
    <Connector port="8443" protocol="org.apache.coyote.http11.Http11AprProtocol"
               maxThreads="150" SSLEnabled="true" >
        <UpgradeProtocol className="org.apache.coyote.http2.Http2Protocol" />
        <SSLHostConfig>
            <Certificate certificateKeyFile="conf/localhost-rsa-key.pem"
                         certificateFile="conf/localhost-rsa-cert.pem"
                         certificateChainFile="conf/localhost-rsa-chain.pem"
                         type="RSA" />
        </SSLHostConfig>
    </Connector>
    -->

    <!-- Define an AJP 1.3 Connector on port 8009 -->
    <!--
    <Connector protocol="AJP/1.3"
               address="::1"
               port="8009"
               redirectPort="8443" />
    -->

    <!-- An Engine represents the entry point (within Catalina) that processes
         every request.  The Engine implementation for Tomcat stand alone
         analyzes the HTTP headers included with the request, and passes them
         on to the appropriate Host (virtual host).
         Documentation at /docs/config/engine.html -->

    <!-- You should set jvmRoute to support load-balancing via AJP ie :
    <Engine name="Catalina" defaultHost="localhost" jvmRoute="jvm1">
    -->
    <Engine name="Catalina" defaultHost="localhost">

      <!--For clustering, please take a look at documentation at:
          /docs/cluster-howto.html  (simple how to)
          /docs/config/cluster.html (reference documentation) -->
      <!--
      <Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster"/>
      -->

      <!-- Use the LockOutRealm to prevent attempts to guess user passwords
           via a brute-force attack -->
      <Realm className="org.apache.catalina.realm.LockOutRealm">
        <!-- This Realm uses the UserDatabase configured in the global JNDI
             resources under the key "UserDatabase".  Any edits
             that are performed against this UserDatabase are immediately
             available for use by the Realm.  -->
        <Realm className="org.apache.catalina.realm.UserDatabaseRealm"
               resourceName="UserDatabase"/>
      </Realm>

      <Host name="localhost"  appBase="webapps"
            unpackWARs="true" autoDeploy="true">

        <!-- SingleSignOn valve, share authentication between web applications
             Documentation at: /docs/config/valve.html -->
        <!--
        <Valve className="org.apache.catalina.authenticator.SingleSignOn" />
        -->

        <!-- Access log processes all example.
             Documentation at: /docs/config/valve.html
             Note: The pattern used is equivalent to using pattern="common" -->
        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="localhost_access_log" suffix=".txt"
               pattern="%h %l %u %t &quot;%r&quot; %s %b" />

      </Host>
    </Engine>
  </Service>
</Server>' > server.xml

	mv server.xml /opt/tomcat1/conf/server.xml


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
	
 	sudo cp tomcat-users.xml /opt/tomcat/conf/tomcat-users.xml
 	sudo cp tomcat-users.xml /opt/tomcat1/conf/tomcat-users.xml
	
	sudo rm -rf tomcat-users.xml

    echo 'Host Manager ve Uzak Erisim Ayarları'
	
	sudo touch context.xml
	
	echo '<?xml version="1.0" encoding="UTF-8"?>
	' >> context.xml
	
	echo '<Context antiResourceLocking="false" privileged="true" >' >> context.xml
	echo ' <Valve className="org.apache.catalina.valves.RemoteAddrValve" allow="10\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />' >> context.xml
	echo '</Context>' >> context.xml
	
	sudo cp context.xml /opt/tomcat/webapps/manager/META-INF/context.xml
	sudo cp context.xml /opt/tomcat/webapps/host-manager/META-INF/context.xml
	sudo cp context.xml /opt/tomcat1/webapps/manager/META-INF/context.xml
	sudo cp context.xml /opt/tomcat1/webapps/host-manager/META-INF/context.xml
	
	sudo rm -rf context.xml
	

    sudo systemctl daemon-reload
    sudo systemctl enable tomcat.service
    sudo systemctl enable tomcat1.service
    sudo firewall-cmd --zone=public --permanent --add-port=8080/tcp
    sudo firewall-cmd --zone=public --permanent --add-port=8081/tcp
    sudo firewall-cmd --reload
    sudo systemctl start tomcat.service
    sudo systemctl start tomcat1.service
	
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
