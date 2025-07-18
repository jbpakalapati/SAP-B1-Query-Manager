<?xml version="1.0" encoding="utf-8" ?>
<configuration>
	<startup>
		<supportedRuntime version="v4.0" sku=".NETFramework,Version=v4.5" />
	</startup>

	<appSettings>

		<add key="DatabaseList" value="DUBAILIMITEDINV,ALMADALLAH,APARTOURS,HPFM,LAVCITYLAUNDRY,TELETRONICS,TADAWI"/>

		<add key="ALMADALLAH" value="Driver={HDBODBC};UID=SYSTEM;PWD=Abcd@1234;SERVERNODE=192.168.150.105:30015;CS={ALMADALLAH}"/>
		<add key="APARTOURS" value="Driver={HDBODBC};UID=SYSTEM;PWD=Abcd@1234;SERVERNODE=192.168.150.105:30015;CS={APARTOURS}"/>
		<add key="DUBAILIMITEDINV" value="Driver={HDBODBC};UID=SYSTEM;PWD=Abcd@1234;SERVERNODE=192.168.150.105:30015;CS={DUBAILIMITEDINV}"/>
		<add key="HPFM" value="Driver={HDBODBC};UID=SYSTEM;PWD=Abcd@1234;SERVERNODE=192.168.150.105:30015;CS={HPFM}"/>
		<add key="LAVCITYLAUNDRY" value="Driver={HDBODBC};UID=SYSTEM;PWD=Abcd@1234;SERVERNODE=192.168.150.105:30015;CS={LAVCITYLAUNDRY}"/>
		<add key="TELETRONICS" value="Driver={HDBODBC};UID=SYSTEM;PWD=Abcd@1234;SERVERNODE=192.168.150.105:30015;CS={TELETRONICS}"/>
		<add key="TADAWI" value="Driver={HDBODBC};UID=SYSTEM;PWD=Abcd@1234;SERVERNODE=192.168.150.105:30015;CS={TADAWI}"/>

		<!--<add key="SQLConnectionString" value="Data Source=192.168.150.102;Initial Catalog=BioTime;User ID=Admin;Password=Wind@w10Pr@"/>-->
		<!--<add key="SQLConnectionString" value="Data Source=192.168.150.102\ZKBIOTIME,1433;Initial Catalog=BioTime;User ID=sa;Password=Abcd@1234;"/>-->
		<!--<add key="DBConnection" value="server=LocalHost;uid=sa;pwd=;database=DataBaseName;Connect Timeout=200; pooling='true'; Max Pool Size=200"/>-->
		<add key="SQLConnectionString" value="Data Source=192.168.150.107,1433;Initial Catalog=BioTime;User ID=sa;Password=sa@12345;"/>

		<!--<add key="SQLConnectionString" value="Data Source=20.74.141.155;Initial Catalog=UNIS;Integrated Security=True;"/>-->

		<!--<add name="connectionstring name " connectionstring="server=SQLserver name; database= databasename; integrated security = true"/>-->

		<!--<add key="MSACCESSConnectionString" value="Provider = Microsoft.Jet.OLEDB.4.0;Data Source=D:\ATT BACKUP\ATT2000.MDB"/>-->
		<add key="MSACCESSConnectionString" value="Provider = Microsoft.Jet.OLEDB.4.0;Data Source=D:\paylite\Paylite Backup file\DATA FILE 23-02-2021\ATT2000.MDB"/>

		<add key="BiometricUSERID" value="admin"/>
		<add key="BiometricPassword" value="Dlita1234"/>
		<add key="BiometricAPI" value="http://dliho.ddns.net:8081/iclock"/>
		<add key="jwtapitoken" value="http://dliho.ddns.net:8081/jwt-api-token-auth"/>
		<add key="TriggerTime" value="300000"/>

		<add key="LogFile" value="C:\Logs\LogBiometric\"/>
		<add key="SourceType" value="SQL"/>

		<!--MSACCESS/SQL/API-->
	</appSettings>

</configuration>