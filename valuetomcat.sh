#sed -i 's/\r$//' test.sh
####### girilen değer kadar tomcat kurulumu yapar opt/tomcat"girilen değer" buraya klasörü oluşturur ve içerisinde port ayarları dahil herşeyi yaparak startlama konumuna getirir.
####### tomcat"girilen değer".service içerisine girilen değere göre ayarlama yapar ve onu opt altında oluşturup sonra /etc/systemd/system altına taşır.

#TOMCAT URL FİXLE #######################
TOMCAT_URL="https://ftp.itu.edu.tr/Mirror/Apache/tomcat/tomcat-9/v9.0.53/bin/apache-tomcat-9.0.53.tar.gz"

#number=5

echo -n "Tomcat Klasörü için bir değer giriniz > " 
read number
if [ ! "$number" == "0" ]; then
    for ((  counter = 1 ; counter <= $number; counter++ ))
    #for ((  counter = 1 ; counter <= 5; counter++ ))
	do
    if (( counter % 1 == 0 ))
	
    then
	#$(( counter )) kullan sayıyı tek tek yazdırıyor.
	if [ ! -d "/opt/tomcat""$(( counter ))" ]
		#if [ ! -d "/opt/tomcat10" ]
		then
			echo 'Tomcat Kuruluyor Verisyon : 9.0...'

		if [ ! -f /opt/apache-tomcat-9*tar.gz ]
		then
			curl -O $TOMCAT_URL
			echo 'Indirme Tamamlandı'
		fi
		    sudo yum install tar -y
			sudo mkdir -p tomcat"$(( counter ))"
			echo 'Tomcat Klasorleri Olusturuldu'
			
			sudo tar xzf apache-tomcat-9*tar.gz -C "/opt/tomcat$(( counter ))" --strip-components=1
			echo 'Tar.gz Klasorden cikartildı'
			
			sudo groupadd tomcat"$(( counter ))"
			useradd -s /bin/false -g tomcat"$(( counter ))" -d /opt/tomcat"$(( counter ))" tomcat"$(( counter ))"
			
			 echo 'Tomcat'"$(( counter ))"' Klasörü Yetkisi Veriliyor'
			 cd "/opt/"
			 sudo chown -hR tomcat"$(( counter ))":tomcat"$(( counter ))" tomcat"$(( counter ))"
			 sudo chmod -R 777 tomcat"$(( counter ))"
			 
			 #sudo chmod -R g+w conf #ne olduğunu bilmiyorum araştıracağım.
			 
			 echo 'Tomcat'"$(( counter ))"' Service Ayarlari'
			 
			 sudo touch tomcat"$(( counter ))".service
			 sudo chmod 777 tomcat"$(( counter ))".service
			 echo "[Unit]" > tomcat"$(( counter ))".service
			 echo "Description=Apache Tomcat Web Application Container" >> tomcat"$(( counter ))".service
			 echo "After=network.target" >> tomcat"$(( counter ))".service

			 echo "[Service]" >> tomcat"$(( counter ))".service
			 echo "Type=forking" >> tomcat"$(( counter ))".service

			 echo "Environment=JAVA_HOME=/usr/lib/jvm/jre" >> tomcat"$(( counter ))".service
			 echo "Environment=CATALINA_PID=/opt/tomcat""$(( counter ))""/temp/tomcat.pid" >> tomcat"$(( counter ))".service
			 echo "Environment=CATALINA_HOME=/opt/tomcat""$(( counter ))" >> tomcat"$(( counter ))".service
			 echo "Environment=CATALINA_BASE=/opt/tomcat""$(( counter ))" >> tomcat"$(( counter ))".service
			 echo "Environment=CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC" >> tomcat"$(( counter ))".service
			 echo "Environment=JAVA_OPTS=-Djava.security.egd=file:///dev/urandom" >> tomcat"$(( counter ))".service

			 echo "ExecStart=/opt/tomcat""$(( counter ))""/bin/startup.sh" >> tomcat"$(( counter ))".service
			 echo "ExecStop=/opt/tomcat""$(( counter ))""/bin/shutdown.sh" >> tomcat"$(( counter ))".service

			 echo 'User=tomcat'"$(( counter ))" >> tomcat"$(( counter ))".service
			 echo 'Group=tomcat'"$(( counter ))" >> tomcat"$(( counter ))".service
			 echo "UMask=0007" >> tomcat"$(( counter ))".service
			 echo "RestartSec=10" >> tomcat"$(( counter ))".service
			 echo "Restart=always" >> tomcat"$(( counter ))".service

			 echo "[Install]" >> tomcat"$(( counter ))".service
			 echo "WantedBy=multi-user.target" >> tomcat"$(( counter ))".service
			 
			 sudo mv tomcat"$(( counter ))".service /etc/systemd/system/tomcat"$(( counter ))".service
			 sudo chmod 755 /etc/systemd/system/tomcat"$(( counter ))".service
			 

		echo 'Tomcat'"$(( counter ))"' Kullanıcı Ayarları Yapılıyor'
	
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
		
		sudo mv tomcat-users.xml /opt/tomcat"$(( counter ))"/conf/tomcat-users.xml
		
		echo 'Tomcat'"$(( counter ))"' Host Manager ve Uzak Erisim Ayarları Yapılıyor'
	
		sudo touch context.xml
	
		echo '<?xml version="1.0" encoding="UTF-8"?>
		' >> context.xml
	
		echo '<Context antiResourceLocking="false" privileged="true" >' >> context.xml
		echo ' <Valve className="org.apache.catalina.valves.RemoteAddrValve" allow="10\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />' >> context.xml
		echo '</Context>' >> context.xml
		
		chmod 777 context.xml
		
		sudo cp context.xml /opt/tomcat"$(( counter ))"/webapps/manager/META-INF/context.xml
		sudo mv context.xml /opt/tomcat"$(( counter ))"/webapps/host-manager/META-INF/context.xml
		
		sudo systemctl daemon-reload
		sudo systemctl enable tomcat"$(( counter ))".service
		sudo firewall-cmd --zone=public --permanent --add-port=808"$(( counter ))"/tcp

		
		systemctl enable tomcat"$(( counter ))".service
		
		#server port +12 lere ulaşıyor buna bir bak
		echo 'tomcat'"$(( counter ))"' Server.Xml ayarları yapılıyor'
		
		
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
<Server port="800'"$(( counter ))"'" shutdown="SHUTDOWN">
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
    <Connector port="808'"$(( counter ))"'" protocol="HTTP/1.1"
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

		sudo cp server.xml /opt/tomcat"$(( counter ))"/conf/server.xml
		
		sudo rm -rf server.xml
		
		sudo touch catalina.sh
		
		
		
		sudo systemctl enable tomcat"$(( counter ))".service
		sudo systemctl start tomcat"$(( counter ))".service
		echo 'Tomcat'"$(( counter ))"' Servisi Çalıştırıldı.'
		#touch tomcat.service
		#echo 'systemctl start tomcat'"$(( counter ))"'.service' > tomcat.service
		

   else
	#
	#read -p 'Tomcat'"$(( counter ))"' Zaten Yüklü Taşıma İşlemi Yapılsın Mı ? [Y/n] :' 
	#  if [[ ! $REPLY =~ ^[Yy]$ ]]
	#  then
	#	exit
	#   else
	#	systemctl stop tomcat"$(( counter ))"
	#	sudo mkdir tomcat"$(( counter ))"-old
	#	  echo 'Tomcat-Old'"$(( counter ))"' Klasörü Oluşturuldu.'
	#	mv tomcat"$(( counter ))"/* /opt/tomcat"$(( counter ))"-old/
	#	  echo 'Tomcat Klasörü Tomcat-Old'"$(( counter ))"' Klasörüne Taşındı'
	#	rm -rf tomcat"$(( counter ))"
	#	  echo 'Tomcat'"$(( counter ))"' Taşınıp eski klasör silindi.'
	#   
	#   
	#  fi	
	echo 'Tomcat'"$(( counter ))"' Zaten Kurulu'
   fi
fi
done	
fi
