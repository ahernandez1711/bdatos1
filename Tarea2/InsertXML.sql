USE test

BEGIN
	SET NOCOUNT ON

/*EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
*/
	DECLARE @xmlData XML = 
	N'<Datos>
	<Puestos>
	<Puesto Id="1" Nombre="Cajero" SalarioxHora="11.00"/>
	<Puesto Id="2" Nombre="Camarero" SalarioxHora="10.00"/>
	<Puesto Id="3" Nombre="Cuidador" SalarioxHora="13.50"/>
	<Puesto Id="4" Nombre="Conductor" SalarioxHora="15.00"/>
	<Puesto Id="5" Nombre="Asistente" SalarioxHora="11.00"/>
	<Puesto Id="6" Nombre="Recepcionista" SalarioxHora="12.00"/>
	<Puesto Id="7" Nombre="Fontanero" SalarioxHora="13.00"/>
	<Puesto Id="8" Nombre="Ni�era" SalarioxHora="12.00"/>
	<Puesto Id="9" Nombre="Conserje" SalarioxHora="11.00"/>
	<Puesto Id="10" Nombre="Alba�il" SalarioxHora="10.50"/>
	</Puestos>
	<TiposEvento>
	<TipoEvento Id="1" Nombre="Login Exitoso"/>
	<TipoEvento Id="2" Nombre="Login No Exitoso"/>
	<TipoEvento Id="3" Nombre="Login deshabilitado"/>
	<TipoEvento Id="4" Nombre="Logout"/>
	<TipoEvento Id="5" Nombre="Insercion no exitosa"/>
	<TipoEvento Id="6" Nombre="Insercion exitosa"/>
	<TipoEvento Id="7" Nombre="Update no exitoso"/>
	<TipoEvento Id="8" Nombre="Update exitoso"/>
	<TipoEvento Id="9" Nombre="Intento de borrado"/>
	<TipoEvento Id="10" Nombre="Borrado exitoso"/>
	<TipoEvento Id="11" Nombre="Consulta con filtro de nombre"/>
	<TipoEvento Id="12" Nombre="Consulta con filtro de cedula"/>
	<TipoEvento Id="13" Nombre="Intento de insertar movimiento"/>
	<TipoEvento Id="14" Nombre="Insertar movimiento exitoso"/>
	</TiposEvento>
	<TiposMovimientos>
	<TipoMovimiento Id="1" Nombre="Cumplir mes" TipoAccion="Credito"/>
	<TipoMovimiento Id="2" Nombre="Bono vacacional" TipoAccion="Credito"/>
	<TipoMovimiento Id="3" Nombre="Reversion Debito" TipoAccion="Credito"/>
	<TipoMovimiento Id="4" Nombre="Disfrute de vacaciones" TipoAccion="Debito"/>
	<TipoMovimiento Id="5" Nombre="Venta de vacaciones" TipoAccion="Debito"/>
	<TipoMovimiento Id="6" Nombre="Reversion de Credito" TipoAccion="Debito"/>
	</TiposMovimientos>
	<Empleados>
	<empleado IdPuesto="7" ValorDocumentoIdentidad="7989721" Nombre="Samantha Pratt" FechaContratacion="2021-07-15" SaldoVacaciones="5" EsActivo="1"/>
	<empleado IdPuesto="5" ValorDocumentoIdentidad="4249098" Nombre="Jeffrey Watson" FechaContratacion="2022-08-20" SaldoVacaciones="10" EsActivo="1"/>
	<empleado IdPuesto="4" ValorDocumentoIdentidad="5380363" Nombre="Carrie Tran" FechaContratacion="2021-04-22" SaldoVacaciones="9" EsActivo="1"/>
	<empleado IdPuesto="10" ValorDocumentoIdentidad="2531660" Nombre="Nancy Richards" FechaContratacion="2018-02-07" SaldoVacaciones="11" EsActivo="1"/>
	<empleado IdPuesto="3" ValorDocumentoIdentidad="3485480" Nombre="Blake Hood" FechaContratacion="2020-09-30" SaldoVacaciones="10" EsActivo="1"/>
	<empleado IdPuesto="2" ValorDocumentoIdentidad="1394620" Nombre="Alexander Dixon" FechaContratacion="2022-05-03" SaldoVacaciones="11" EsActivo="1"/>
	<empleado IdPuesto="5" ValorDocumentoIdentidad="1057958" Nombre="Matthew Martin" FechaContratacion="2025-02-19" SaldoVacaciones="13" EsActivo="1"/>
	<empleado IdPuesto="3" ValorDocumentoIdentidad="4001003" Nombre="Matthew Rodriguez" FechaContratacion="2025-02-07" SaldoVacaciones="14" EsActivo="1"/>
	<empleado IdPuesto="9" ValorDocumentoIdentidad="4047643" Nombre="Crystal Mills" FechaContratacion="2020-11-17" SaldoVacaciones="7" EsActivo="1"/>
	<empleado IdPuesto="6" ValorDocumentoIdentidad="1675299" Nombre="Shane Robinson" FechaContratacion="2024-09-17" SaldoVacaciones="6" EsActivo="1"/>
	<empleado IdPuesto="9" ValorDocumentoIdentidad="4117682" Nombre="Jeffrey Moon" FechaContratacion="2017-06-23" SaldoVacaciones="11" EsActivo="1"/>
	<empleado IdPuesto="10" ValorDocumentoIdentidad="1696912" Nombre="Elizabeth Lin" FechaContratacion="2015-06-06" SaldoVacaciones="13" EsActivo="1"/>
	<empleado IdPuesto="3" ValorDocumentoIdentidad="3521153" Nombre="Hannah Peterson" FechaContratacion="2021-11-01" SaldoVacaciones="7" EsActivo="1"/>
	<empleado IdPuesto="4" ValorDocumentoIdentidad="6431803" Nombre="Antonio Wallace" FechaContratacion="2021-11-14" SaldoVacaciones="6" EsActivo="1"/>
	<empleado IdPuesto="4" ValorDocumentoIdentidad="4011255" Nombre="Patricia Richardson" FechaContratacion="2023-12-27" SaldoVacaciones="10" EsActivo="1"/>
	<empleado IdPuesto="6" ValorDocumentoIdentidad="3038513" Nombre="Mr. Mark Nguyen" FechaContratacion="2022-06-05" SaldoVacaciones="5" EsActivo="1"/>
	<empleado IdPuesto="8" ValorDocumentoIdentidad="4382196" Nombre="Matthew Wilson" FechaContratacion="2017-10-24" SaldoVacaciones="10" EsActivo="1"/>
	<empleado IdPuesto="1" ValorDocumentoIdentidad="2342953" Nombre="Steven Rogers II" FechaContratacion="2018-01-14" SaldoVacaciones="13" EsActivo="1"/>
	<empleado IdPuesto="7" ValorDocumentoIdentidad="5836798" Nombre="Brandon Dominguez" FechaContratacion="2017-10-05" SaldoVacaciones="5" EsActivo="1"/>
	<empleado IdPuesto="1" ValorDocumentoIdentidad="1053434" Nombre="Stacey Conley" FechaContratacion="2016-11-24" SaldoVacaciones="15" EsActivo="1"/>
	<empleado IdPuesto="3" ValorDocumentoIdentidad="5433860" Nombre="Jennifer Tyler" FechaContratacion="2023-02-09" SaldoVacaciones="14" EsActivo="1"/>
	<empleado IdPuesto="3" ValorDocumentoIdentidad="7991371" Nombre="Thomas Lopez" FechaContratacion="2021-08-12" SaldoVacaciones="9" EsActivo="1"/>
	<empleado IdPuesto="2" ValorDocumentoIdentidad="6544296" Nombre="Christopher Duncan" FechaContratacion="2024-02-01" SaldoVacaciones="15" EsActivo="1"/>
	<empleado IdPuesto="7" ValorDocumentoIdentidad="5176529" Nombre="Kayla Butler" FechaContratacion="2017-04-24" SaldoVacaciones="6" EsActivo="1"/>
	<empleado IdPuesto="10" ValorDocumentoIdentidad="2135917" Nombre="Natasha Fuller" FechaContratacion="2024-12-26" SaldoVacaciones="7" EsActivo="1"/>
	<empleado IdPuesto="7" ValorDocumentoIdentidad="4387142" Nombre="Kiara Hall" FechaContratacion="2024-12-05" SaldoVacaciones="8" EsActivo="1"/>
	<empleado IdPuesto="9" ValorDocumentoIdentidad="5904068" Nombre="Jordan Wise" FechaContratacion="2016-04-10" SaldoVacaciones="14" EsActivo="1"/>
	<empleado IdPuesto="6" ValorDocumentoIdentidad="5361005" Nombre="Amanda Lloyd" FechaContratacion="2024-05-20" SaldoVacaciones="5" EsActivo="1"/>
	<empleado IdPuesto="4" ValorDocumentoIdentidad="2804664" Nombre="Andrea Watson" FechaContratacion="2015-11-14" SaldoVacaciones="6" EsActivo="1"/>
	<empleado IdPuesto="8" ValorDocumentoIdentidad="5612560" Nombre="Melissa Morales" FechaContratacion="2022-11-29" SaldoVacaciones="8" EsActivo="1"/>
	</Empleados>
	<Usuarios>
	<usuario Id="1" Nombre="UsuarioScripts" Pass="1234"/>
	<usuario Id="2" Nombre="Arturo" Pass="4325"/>
	<usuario Id="3" Nombre="Alejandro" Pass="test"/>
	<usuario Id="4" Nombre="Franco" Pass="tset"/>
	<usuario Id="5" Nombre="Daniel" Pass="4321"/>
	<usuario Id="6" Nombre="Axel" Pass="2465"/>
	</Usuarios>
	<Feriados>
	<Feriado Fecha="2024-01-01" Descripcion="A�o Nuevo"/>
	<Feriado Fecha="2024-05-01" Descripcion="D�a del Trabajo"/>
	<Feriado Fecha="2024-09-16" Descripcion="D�a de la Independencia"/>
	<Feriado Fecha="2024-11-01" Descripcion="D�a de Todos los Santos"/>
	<Feriado Fecha="2024-12-25" Descripcion="Navidad"/>
	</Feriados>
	<Movimientos>
	<movimiento ValorDocId="7989721" IdTipoMovimiento="6" Fecha="2024-01-01" Monto="3" PostByUser="Axel" PostInIP="147.245.84.48" PostTime="2024-01-01 10:16:37"/>
	<movimiento ValorDocId="7989721" IdTipoMovimiento="4" Fecha="2024-02-01" Monto="1" PostByUser="UsuarioScripts" PostInIP="191.95.123.55" PostTime="2024-02-01 10:19:55"/>
	<movimiento ValorDocId="7989721" IdTipoMovimiento="1" Fecha="2024-03-01" Monto="1" PostByUser="Arturo" PostInIP="92.132.6.143" PostTime="2024-03-01 13:34:21"/>
	<movimiento ValorDocId="7989721" IdTipoMovimiento="2" Fecha="2024-04-01" Monto="2" PostByUser="Alejandro" PostInIP="86.21.166.166" PostTime="2024-04-01 08:03:03"/>
	<movimiento ValorDocId="7989721" IdTipoMovimiento="6" Fecha="2024-05-01" Monto="2" PostByUser="UsuarioScripts" PostInIP="64.33.87.154" PostTime="2024-05-01 14:51:58"/>
	<movimiento ValorDocId="7989721" IdTipoMovimiento="2" Fecha="2024-06-01" Monto="1" PostByUser="Axel" PostInIP="133.82.56.156" PostTime="2024-06-01 13:13:43"/>
	<movimiento ValorDocId="7989721" IdTipoMovimiento="5" Fecha="2024-07-01" Monto="1" PostByUser="Franco" PostInIP="76.7.98.161" PostTime="2024-07-01 17:03:00"/>
	<movimiento ValorDocId="7989721" IdTipoMovimiento="6" Fecha="2024-08-01" Monto="1" PostByUser="Alejandro" PostInIP="223.178.103.185" PostTime="2024-08-01 17:26:59"/>
	<movimiento ValorDocId="7989721" IdTipoMovimiento="3" Fecha="2024-09-01" Monto="1" PostByUser="Alejandro" PostInIP="98.203.4.142" PostTime="2024-09-01 18:44:07"/>
	<movimiento ValorDocId="7989721" IdTipoMovimiento="5" Fecha="2024-10-01" Monto="1" PostByUser="UsuarioScripts" PostInIP="101.153.173.20" PostTime="2024-10-01 15:10:57"/>
	<movimiento ValorDocId="4249098" IdTipoMovimiento="3" Fecha="2024-01-01" Monto="1" PostByUser="Arturo" PostInIP="188.108.198.144" PostTime="2024-01-01 10:10:18"/>
	<movimiento ValorDocId="4249098" IdTipoMovimiento="2" Fecha="2024-02-01" Monto="3" PostByUser="UsuarioScripts" PostInIP="83.65.4.151" PostTime="2024-02-01 16:44:00"/>
	<movimiento ValorDocId="4249098" IdTipoMovimiento="2" Fecha="2024-03-01" Monto="1" PostByUser="Axel" PostInIP="34.150.192.224" PostTime="2024-03-01 15:56:11"/>
	<movimiento ValorDocId="4249098" IdTipoMovimiento="5" Fecha="2024-04-01" Monto="1" PostByUser="Alejandro" PostInIP="42.70.15.178" PostTime="2024-04-01 16:48:25"/>
	<movimiento ValorDocId="4249098" IdTipoMovimiento="1" Fecha="2024-05-01" Monto="2" PostByUser="Franco" PostInIP="83.157.229.153" PostTime="2024-05-01 10:15:58"/>
	<movimiento ValorDocId="4249098" IdTipoMovimiento="2" Fecha="2024-06-01" Monto="1" PostByUser="Alejandro" PostInIP="118.201.230.46" PostTime="2024-06-01 13:11:25"/>
	<movimiento ValorDocId="4249098" IdTipoMovimiento="2" Fecha="2024-07-01" Monto="1" PostByUser="Daniel" PostInIP="102.153.127.242" PostTime="2024-07-01 18:52:33"/>
	<movimiento ValorDocId="4249098" IdTipoMovimiento="2" Fecha="2024-08-01" Monto="2" PostByUser="Daniel" PostInIP="66.4.134.79" PostTime="2024-08-01 14:20:07"/>
	<movimiento ValorDocId="4249098" IdTipoMovimiento="1" Fecha="2024-09-01" Monto="3" PostByUser="Franco" PostInIP="165.116.216.129" PostTime="2024-09-01 11:40:39"/>
	<movimiento ValorDocId="4249098" IdTipoMovimiento="5" Fecha="2024-10-01" Monto="1" PostByUser="Axel" PostInIP="34.156.170.139" PostTime="2024-10-01 10:33:57"/>
	<movimiento ValorDocId="5380363" IdTipoMovimiento="2" Fecha="2024-01-01" Monto="2" PostByUser="Daniel" PostInIP="119.193.19.48" PostTime="2024-01-01 12:08:34"/>
	<movimiento ValorDocId="5380363" IdTipoMovimiento="5" Fecha="2024-02-01" Monto="3" PostByUser="Axel" PostInIP="107.76.212.252" PostTime="2024-02-01 08:16:49"/>
	<movimiento ValorDocId="5380363" IdTipoMovimiento="4" Fecha="2024-03-01" Monto="1" PostByUser="Alejandro" PostInIP="122.223.3.133" PostTime="2024-03-01 16:34:36"/>
	<movimiento ValorDocId="5380363" IdTipoMovimiento="1" Fecha="2024-04-01" Monto="3" PostByUser="UsuarioScripts" PostInIP="108.139.182.227" PostTime="2024-04-01 10:23:56"/>
	<movimiento ValorDocId="5380363" IdTipoMovimiento="6" Fecha="2024-05-01" Monto="3" PostByUser="UsuarioScripts" PostInIP="69.223.161.19" PostTime="2024-05-01 12:47:28"/>
	<movimiento ValorDocId="5380363" IdTipoMovimiento="6" Fecha="2024-06-01" Monto="2" PostByUser="Franco" PostInIP="77.68.219.208" PostTime="2024-06-01 12:28:39"/>
	<movimiento ValorDocId="5380363" IdTipoMovimiento="3" Fecha="2024-07-01" Monto="2" PostByUser="Axel" PostInIP="7.71.245.132" PostTime="2024-07-01 15:30:03"/>
	<movimiento ValorDocId="5380363" IdTipoMovimiento="3" Fecha="2024-08-01" Monto="2" PostByUser="UsuarioScripts" PostInIP="192.80.62.80" PostTime="2024-08-01 11:22:08"/>
	<movimiento ValorDocId="5380363" IdTipoMovimiento="1" Fecha="2024-09-01" Monto="3" PostByUser="Axel" PostInIP="180.217.236.38" PostTime="2024-09-01 09:01:07"/>
	<movimiento ValorDocId="5380363" IdTipoMovimiento="5" Fecha="2024-10-01" Monto="1" PostByUser="Franco" PostInIP="148.210.171.86" PostTime="2024-10-01 15:11:17"/>
	<movimiento ValorDocId="2531660" IdTipoMovimiento="3" Fecha="2024-01-01" Monto="1" PostByUser="Alejandro" PostInIP="138.122.62.130" PostTime="2024-01-01 13:54:24"/>
	<movimiento ValorDocId="2531660" IdTipoMovimiento="1" Fecha="2024-02-01" Monto="3" PostByUser="Alejandro" PostInIP="30.17.81.162" PostTime="2024-02-01 13:50:55"/>
	<movimiento ValorDocId="2531660" IdTipoMovimiento="1" Fecha="2024-03-01" Monto="2" PostByUser="Arturo" PostInIP="65.192.36.222" PostTime="2024-03-01 10:05:09"/>
	<movimiento ValorDocId="2531660" IdTipoMovimiento="3" Fecha="2024-04-01" Monto="1" PostByUser="Alejandro" PostInIP="219.80.25.2" PostTime="2024-04-01 14:12:00"/>
	<movimiento ValorDocId="2531660" IdTipoMovimiento="2" Fecha="2024-05-01" Monto="1" PostByUser="Daniel" PostInIP="129.23.40.219" PostTime="2024-05-01 08:50:21"/>
	<movimiento ValorDocId="2531660" IdTipoMovimiento="4" Fecha="2024-06-01" Monto="2" PostByUser="UsuarioScripts" PostInIP="60.2.89.0" PostTime="2024-06-01 11:06:31"/>
	<movimiento ValorDocId="2531660" IdTipoMovimiento="2" Fecha="2024-07-01" Monto="3" PostByUser="Arturo" PostInIP="84.11.212.140" PostTime="2024-07-01 12:36:34"/>
	<movimiento ValorDocId="2531660" IdTipoMovimiento="3" Fecha="2024-08-01" Monto="1" PostByUser="Axel" PostInIP="51.26.28.186" PostTime="2024-08-01 12:02:54"/>
	<movimiento ValorDocId="2531660" IdTipoMovimiento="1" Fecha="2024-09-01" Monto="1" PostByUser="Daniel" PostInIP="67.161.71.254" PostTime="2024-09-01 11:35:32"/>
	<movimiento ValorDocId="2531660" IdTipoMovimiento="6" Fecha="2024-10-01" Monto="2" PostByUser="Daniel" PostInIP="159.29.119.171" PostTime="2024-10-01 08:49:33"/>
	<movimiento ValorDocId="3485480" IdTipoMovimiento="2" Fecha="2024-01-01" Monto="3" PostByUser="Daniel" PostInIP="200.98.184.157" PostTime="2024-01-01 13:37:48"/>
	<movimiento ValorDocId="3485480" IdTipoMovimiento="2" Fecha="2024-02-01" Monto="2" PostByUser="Franco" PostInIP="130.32.239.76" PostTime="2024-02-01 15:01:23"/>
	<movimiento ValorDocId="3485480" IdTipoMovimiento="6" Fecha="2024-03-01" Monto="1" PostByUser="Franco" PostInIP="206.120.134.209" PostTime="2024-03-01 13:43:52"/>
	<movimiento ValorDocId="3485480" IdTipoMovimiento="5" Fecha="2024-04-01" Monto="3" PostByUser="Daniel" PostInIP="172.197.138.139" PostTime="2024-04-01 08:20:30"/>
	<movimiento ValorDocId="3485480" IdTipoMovimiento="4" Fecha="2024-05-01" Monto="1" PostByUser="Alejandro" PostInIP="31.2.215.204" PostTime="2024-05-01 13:24:51"/>
	<movimiento ValorDocId="3485480" IdTipoMovimiento="3" Fecha="2024-06-01" Monto="1" PostByUser="Franco" PostInIP="78.21.90.214" PostTime="2024-06-01 17:39:03"/>
	<movimiento ValorDocId="3485480" IdTipoMovimiento="5" Fecha="2024-07-01" Monto="1" PostByUser="Franco" PostInIP="218.139.114.19" PostTime="2024-07-01 09:06:39"/>
	<movimiento ValorDocId="3485480" IdTipoMovimiento="2" Fecha="2024-08-01" Monto="1" PostByUser="UsuarioScripts" PostInIP="181.48.43.251" PostTime="2024-08-01 12:53:13"/>
	<movimiento ValorDocId="3485480" IdTipoMovimiento="5" Fecha="2024-09-01" Monto="1" PostByUser="Franco" PostInIP="47.119.222.239" PostTime="2024-09-01 15:30:03"/>
	<movimiento ValorDocId="3485480" IdTipoMovimiento="4" Fecha="2024-10-01" Monto="1" PostByUser="Arturo" PostInIP="198.63.139.140" PostTime="2024-10-01 13:47:50"/>
	<movimiento ValorDocId="1394620" IdTipoMovimiento="2" Fecha="2024-01-01" Monto="2" PostByUser="Daniel" PostInIP="214.171.198.180" PostTime="2024-01-01 16:15:43"/>
	<movimiento ValorDocId="1394620" IdTipoMovimiento="4" Fecha="2024-02-01" Monto="1" PostByUser="Arturo" PostInIP="2.219.3.22" PostTime="2024-02-01 16:36:59"/>
	<movimiento ValorDocId="1394620" IdTipoMovimiento="5" Fecha="2024-03-01" Monto="3" PostByUser="Arturo" PostInIP="111.73.135.30" PostTime="2024-03-01 10:43:46"/>
	<movimiento ValorDocId="1394620" IdTipoMovimiento="4" Fecha="2024-04-01" Monto="1" PostByUser="Axel" PostInIP="168.7.102.48" PostTime="2024-04-01 11:04:50"/>
	<movimiento ValorDocId="1394620" IdTipoMovimiento="1" Fecha="2024-05-01" Monto="3" PostByUser="UsuarioScripts" PostInIP="132.175.132.16" PostTime="2024-05-01 09:16:36"/>
	<movimiento ValorDocId="1394620" IdTipoMovimiento="2" Fecha="2024-06-01" Monto="1" PostByUser="Alejandro" PostInIP="161.29.177.23" PostTime="2024-06-01 11:31:23"/>
	<movimiento ValorDocId="1394620" IdTipoMovimiento="6" Fecha="2024-07-01" Monto="3" PostByUser="Franco" PostInIP="2.125.62.211" PostTime="2024-07-01 18:25:35"/>
	<movimiento ValorDocId="1394620" IdTipoMovimiento="2" Fecha="2024-08-01" Monto="3" PostByUser="Franco" PostInIP="79.21.245.173" PostTime="2024-08-01 16:06:33"/>
	<movimiento ValorDocId="1394620" IdTipoMovimiento="1" Fecha="2024-09-01" Monto="3" PostByUser="Daniel" PostInIP="100.199.18.84" PostTime="2024-09-01 18:23:15"/>
	<movimiento ValorDocId="1394620" IdTipoMovimiento="4" Fecha="2024-10-01" Monto="2" PostByUser="Axel" PostInIP="117.236.5.51" PostTime="2024-10-01 09:26:29"/>
	<movimiento ValorDocId="1057958" IdTipoMovimiento="1" Fecha="2024-01-01" Monto="2" PostByUser="Arturo" PostInIP="190.75.163.168" PostTime="2024-01-01 15:19:27"/>
	<movimiento ValorDocId="1057958" IdTipoMovimiento="5" Fecha="2024-02-01" Monto="1" PostByUser="Arturo" PostInIP="143.241.204.183" PostTime="2024-02-01 11:46:39"/>
	<movimiento ValorDocId="1057958" IdTipoMovimiento="4" Fecha="2024-03-01" Monto="2" PostByUser="Daniel" PostInIP="134.240.203.95" PostTime="2024-03-01 18:49:51"/>
	<movimiento ValorDocId="1057958" IdTipoMovimiento="2" Fecha="2024-04-01" Monto="3" PostByUser="UsuarioScripts" PostInIP="13.227.62.132" PostTime="2024-04-01 16:46:46"/>
	<movimiento ValorDocId="1057958" IdTipoMovimiento="3" Fecha="2024-05-01" Monto="1" PostByUser="Franco" PostInIP="119.228.54.82" PostTime="2024-05-01 13:44:40"/>
	<movimiento ValorDocId="1057958" IdTipoMovimiento="2" Fecha="2024-06-01" Monto="3" PostByUser="Alejandro" PostInIP="154.250.1.122" PostTime="2024-06-01 08:46:25"/>
	<movimiento ValorDocId="1057958" IdTipoMovimiento="3" Fecha="2024-07-01" Monto="1" PostByUser="Daniel" PostInIP="26.124.251.213" PostTime="2024-07-01 12:14:05"/>
	<movimiento ValorDocId="1057958" IdTipoMovimiento="2" Fecha="2024-08-01" Monto="2" PostByUser="Daniel" PostInIP="116.220.9.75" PostTime="2024-08-01 08:01:09"/>
	<movimiento ValorDocId="1057958" IdTipoMovimiento="5" Fecha="2024-09-01" Monto="3" PostByUser="Arturo" PostInIP="39.249.142.80" PostTime="2024-09-01 13:13:08"/>
	<movimiento ValorDocId="1057958" IdTipoMovimiento="5" Fecha="2024-10-01" Monto="3" PostByUser="Alejandro" PostInIP="110.40.82.194" PostTime="2024-10-01 16:18:01"/>
	<movimiento ValorDocId="4001003" IdTipoMovimiento="2" Fecha="2024-01-01" Monto="2" PostByUser="Franco" PostInIP="121.104.116.168" PostTime="2024-01-01 18:37:25"/>
	<movimiento ValorDocId="4001003" IdTipoMovimiento="6" Fecha="2024-02-01" Monto="3" PostByUser="Axel" PostInIP="145.174.155.233" PostTime="2024-02-01 18:51:28"/>
	<movimiento ValorDocId="4001003" IdTipoMovimiento="5" Fecha="2024-03-01" Monto="3" PostByUser="Alejandro" PostInIP="94.173.27.42" PostTime="2024-03-01 16:18:34"/>
	<movimiento ValorDocId="4001003" IdTipoMovimiento="1" Fecha="2024-04-01" Monto="3" PostByUser="Franco" PostInIP="214.115.169.217" PostTime="2024-04-01 15:58:41"/>
	<movimiento ValorDocId="4001003" IdTipoMovimiento="2" Fecha="2024-05-01" Monto="2" PostByUser="UsuarioScripts" PostInIP="164.213.222.45" PostTime="2024-05-01 09:46:57"/>
	<movimiento ValorDocId="4001003" IdTipoMovimiento="1" Fecha="2024-06-01" Monto="2" PostByUser="Axel" PostInIP="89.115.232.108" PostTime="2024-06-01 13:56:26"/>
	<movimiento ValorDocId="4001003" IdTipoMovimiento="6" Fecha="2024-07-01" Monto="2" PostByUser="Franco" PostInIP="48.7.0.43" PostTime="2024-07-01 09:24:44"/>
	<movimiento ValorDocId="4001003" IdTipoMovimiento="6" Fecha="2024-08-01" Monto="1" PostByUser="Axel" PostInIP="115.67.179.53" PostTime="2024-08-01 14:14:39"/>
	<movimiento ValorDocId="4001003" IdTipoMovimiento="1" Fecha="2024-09-01" Monto="2" PostByUser="Arturo" PostInIP="112.23.245.180" PostTime="2024-09-01 18:00:22"/>
	<movimiento ValorDocId="4001003" IdTipoMovimiento="2" Fecha="2024-10-01" Monto="3" PostByUser="Alejandro" PostInIP="72.136.28.99" PostTime="2024-10-01 10:24:10"/>
	<movimiento ValorDocId="4047643" IdTipoMovimiento="3" Fecha="2024-01-01" Monto="2" PostByUser="Axel" PostInIP="40.55.197.114" PostTime="2024-01-01 17:20:27"/>
	<movimiento ValorDocId="4047643" IdTipoMovimiento="1" Fecha="2024-02-01" Monto="2" PostByUser="Arturo" PostInIP="174.115.186.50" PostTime="2024-02-01 17:55:29"/>
	<movimiento ValorDocId="4047643" IdTipoMovimiento="1" Fecha="2024-03-01" Monto="2" PostByUser="Axel" PostInIP="8.118.195.163" PostTime="2024-03-01 14:31:08"/>
	<movimiento ValorDocId="4047643" IdTipoMovimiento="5" Fecha="2024-04-01" Monto="2" PostByUser="Axel" PostInIP="101.201.97.121" PostTime="2024-04-01 17:52:57"/>
	<movimiento ValorDocId="4047643" IdTipoMovimiento="3" Fecha="2024-05-01" Monto="3" PostByUser="Arturo" PostInIP="220.217.113.153" PostTime="2024-05-01 15:28:44"/>
	<movimiento ValorDocId="4047643" IdTipoMovimiento="1" Fecha="2024-06-01" Monto="2" PostByUser="Alejandro" PostInIP="167.10.227.201" PostTime="2024-06-01 11:26:30"/>
	<movimiento ValorDocId="4047643" IdTipoMovimiento="2" Fecha="2024-07-01" Monto="3" PostByUser="Daniel" PostInIP="145.235.50.64" PostTime="2024-07-01 13:31:18"/>
	<movimiento ValorDocId="4047643" IdTipoMovimiento="5" Fecha="2024-08-01" Monto="1" PostByUser="Franco" PostInIP="9.43.143.191" PostTime="2024-08-01 13:58:06"/>
	<movimiento ValorDocId="4047643" IdTipoMovimiento="2" Fecha="2024-09-01" Monto="1" PostByUser="Daniel" PostInIP="158.226.13.244" PostTime="2024-09-01 08:48:45"/>
	<movimiento ValorDocId="4047643" IdTipoMovimiento="6" Fecha="2024-10-01" Monto="1" PostByUser="Franco" PostInIP="213.19.195.204" PostTime="2024-10-01 10:23:04"/>
	<movimiento ValorDocId="1675299" IdTipoMovimiento="2" Fecha="2024-01-01" Monto="3" PostByUser="Arturo" PostInIP="209.133.41.205" PostTime="2024-01-01 08:06:21"/>
	<movimiento ValorDocId="1675299" IdTipoMovimiento="3" Fecha="2024-02-01" Monto="3" PostByUser="Arturo" PostInIP="135.161.137.48" PostTime="2024-02-01 18:34:39"/>
	<movimiento ValorDocId="1675299" IdTipoMovimiento="3" Fecha="2024-03-01" Monto="3" PostByUser="Daniel" PostInIP="122.132.138.3" PostTime="2024-03-01 12:22:20"/>
	<movimiento ValorDocId="1675299" IdTipoMovimiento="4" Fecha="2024-04-01" Monto="1" PostByUser="Daniel" PostInIP="220.142.69.130" PostTime="2024-04-01 09:37:28"/>
	<movimiento ValorDocId="1675299" IdTipoMovimiento="4" Fecha="2024-05-01" Monto="3" PostByUser="Alejandro" PostInIP="28.120.235.52" PostTime="2024-05-01 11:16:06"/>
	<movimiento ValorDocId="1675299" IdTipoMovimiento="2" Fecha="2024-06-01" Monto="3" PostByUser="Alejandro" PostInIP="135.193.69.129" PostTime="2024-06-01 18:03:32"/>
	<movimiento ValorDocId="1675299" IdTipoMovimiento="2" Fecha="2024-07-01" Monto="1" PostByUser="Daniel" PostInIP="183.91.36.40" PostTime="2024-07-01 11:44:17"/>
	<movimiento ValorDocId="1675299" IdTipoMovimiento="2" Fecha="2024-08-01" Monto="2" PostByUser="Alejandro" PostInIP="196.7.120.101" PostTime="2024-08-01 08:05:59"/>
	<movimiento ValorDocId="1675299" IdTipoMovimiento="6" Fecha="2024-09-01" Monto="1" PostByUser="Axel" PostInIP="180.250.10.88" PostTime="2024-09-01 11:45:02"/>
	<movimiento ValorDocId="1675299" IdTipoMovimiento="2" Fecha="2024-10-01" Monto="1" PostByUser="UsuarioScripts" PostInIP="150.199.238.216" PostTime="2024-10-01 10:24:27"/>
	<movimiento ValorDocId="4117682" IdTipoMovimiento="5" Fecha="2024-01-01" Monto="2" PostByUser="UsuarioScripts" PostInIP="108.81.90.164" PostTime="2024-01-01 10:09:43"/>
	<movimiento ValorDocId="4117682" IdTipoMovimiento="5" Fecha="2024-02-01" Monto="3" PostByUser="Arturo" PostInIP="220.100.115.246" PostTime="2024-02-01 15:52:06"/>
	<movimiento ValorDocId="4117682" IdTipoMovimiento="3" Fecha="2024-03-01" Monto="3" PostByUser="UsuarioScripts" PostInIP="109.40.250.112" PostTime="2024-03-01 10:01:04"/>
	<movimiento ValorDocId="4117682" IdTipoMovimiento="3" Fecha="2024-04-01" Monto="1" PostByUser="Alejandro" PostInIP="148.60.105.254" PostTime="2024-04-01 13:13:18"/>
	<movimiento ValorDocId="4117682" IdTipoMovimiento="2" Fecha="2024-05-01" Monto="3" PostByUser="Alejandro" PostInIP="27.85.114.188" PostTime="2024-05-01 14:04:21"/>
	<movimiento ValorDocId="4117682" IdTipoMovimiento="2" Fecha="2024-06-01" Monto="2" PostByUser="Franco" PostInIP="119.83.38.174" PostTime="2024-06-01 16:10:35"/>
	<movimiento ValorDocId="4117682" IdTipoMovimiento="6" Fecha="2024-07-01" Monto="1" PostByUser="Franco" PostInIP="89.25.53.67" PostTime="2024-07-01 08:28:09"/>
	<movimiento ValorDocId="4117682" IdTipoMovimiento="3" Fecha="2024-08-01" Monto="1" PostByUser="Axel" PostInIP="27.248.19.26" PostTime="2024-08-01 10:35:47"/>
	<movimiento ValorDocId="4117682" IdTipoMovimiento="5" Fecha="2024-09-01" Monto="2" PostByUser="Axel" PostInIP="217.142.189.61" PostTime="2024-09-01 12:18:44"/>
	<movimiento ValorDocId="4117682" IdTipoMovimiento="1" Fecha="2024-10-01" Monto="3" PostByUser="Daniel" PostInIP="162.29.218.234" PostTime="2024-10-01 13:45:25"/>
	<movimiento ValorDocId="1696912" IdTipoMovimiento="5" Fecha="2024-01-01" Monto="1" PostByUser="Franco" PostInIP="16.91.80.5" PostTime="2024-01-01 09:57:58"/>
	<movimiento ValorDocId="1696912" IdTipoMovimiento="1" Fecha="2024-02-01" Monto="3" PostByUser="Daniel" PostInIP="27.195.92.136" PostTime="2024-02-01 10:29:51"/>
	<movimiento ValorDocId="1696912" IdTipoMovimiento="5" Fecha="2024-03-01" Monto="1" PostByUser="UsuarioScripts" PostInIP="119.140.122.247" PostTime="2024-03-01 18:53:37"/>
	<movimiento ValorDocId="1696912" IdTipoMovimiento="1" Fecha="2024-04-01" Monto="1" PostByUser="Franco" PostInIP="117.112.223.82" PostTime="2024-04-01 10:48:46"/>
	<movimiento ValorDocId="1696912" IdTipoMovimiento="1" Fecha="2024-05-01" Monto="2" PostByUser="Axel" PostInIP="23.80.167.61" PostTime="2024-05-01 09:25:16"/>
	<movimiento ValorDocId="1696912" IdTipoMovimiento="3" Fecha="2024-06-01" Monto="1" PostByUser="Daniel" PostInIP="218.58.125.219" PostTime="2024-06-01 16:14:51"/>
	<movimiento ValorDocId="1696912" IdTipoMovimiento="6" Fecha="2024-07-01" Monto="1" PostByUser="Axel" PostInIP="212.204.81.7" PostTime="2024-07-01 09:27:09"/>
	<movimiento ValorDocId="1696912" IdTipoMovimiento="3" Fecha="2024-08-01" Monto="1" PostByUser="UsuarioScripts" PostInIP="96.94.202.23" PostTime="2024-08-01 18:20:42"/>
	<movimiento ValorDocId="1696912" IdTipoMovimiento="4" Fecha="2024-09-01" Monto="3" PostByUser="Axel" PostInIP="179.239.41.243" PostTime="2024-09-01 17:50:16"/>
	<movimiento ValorDocId="1696912" IdTipoMovimiento="2" Fecha="2024-10-01" Monto="2" PostByUser="Franco" PostInIP="180.1.76.220" PostTime="2024-10-01 12:00:18"/>
	<movimiento ValorDocId="3521153" IdTipoMovimiento="6" Fecha="2024-01-01" Monto="3" PostByUser="Daniel" PostInIP="44.211.124.21" PostTime="2024-01-01 14:28:26"/>
	<movimiento ValorDocId="3521153" IdTipoMovimiento="4" Fecha="2024-02-01" Monto="1" PostByUser="Franco" PostInIP="128.18.200.230" PostTime="2024-02-01 15:14:37"/>
	<movimiento ValorDocId="3521153" IdTipoMovimiento="1" Fecha="2024-03-01" Monto="2" PostByUser="Arturo" PostInIP="80.177.128.172" PostTime="2024-03-01 16:12:14"/>
	<movimiento ValorDocId="3521153" IdTipoMovimiento="1" Fecha="2024-04-01" Monto="3" PostByUser="Daniel" PostInIP="145.184.143.225" PostTime="2024-04-01 11:11:08"/>
	<movimiento ValorDocId="3521153" IdTipoMovimiento="2" Fecha="2024-05-01" Monto="3" PostByUser="UsuarioScripts" PostInIP="201.61.253.138" PostTime="2024-05-01 09:08:00"/>
	<movimiento ValorDocId="3521153" IdTipoMovimiento="1" Fecha="2024-06-01" Monto="2" PostByUser="UsuarioScripts" PostInIP="57.17.166.111" PostTime="2024-06-01 16:19:53"/>
	<movimiento ValorDocId="3521153" IdTipoMovimiento="1" Fecha="2024-07-01" Monto="2" PostByUser="Daniel" PostInIP="71.191.119.234" PostTime="2024-07-01 17:14:21"/>
	<movimiento ValorDocId="3521153" IdTipoMovimiento="6" Fecha="2024-08-01" Monto="1" PostByUser="UsuarioScripts" PostInIP="156.45.38.77" PostTime="2024-08-01 08:41:26"/>
	<movimiento ValorDocId="3521153" IdTipoMovimiento="1" Fecha="2024-09-01" Monto="2" PostByUser="Franco" PostInIP="143.21.99.221" PostTime="2024-09-01 09:04:24"/>
	<movimiento ValorDocId="3521153" IdTipoMovimiento="2" Fecha="2024-10-01" Monto="2" PostByUser="Alejandro" PostInIP="121.94.162.29" PostTime="2024-10-01 15:47:42"/>
	<movimiento ValorDocId="6431803" IdTipoMovimiento="2" Fecha="2024-01-01" Monto="3" PostByUser="Daniel" PostInIP="131.228.174.169" PostTime="2024-01-01 14:54:15"/>
	<movimiento ValorDocId="6431803" IdTipoMovimiento="4" Fecha="2024-02-01" Monto="1" PostByUser="Franco" PostInIP="10.65.85.41" PostTime="2024-02-01 18:53:22"/>
	<movimiento ValorDocId="6431803" IdTipoMovimiento="6" Fecha="2024-03-01" Monto="1" PostByUser="Franco" PostInIP="12.74.35.95" PostTime="2024-03-01 08:29:22"/>
	<movimiento ValorDocId="6431803" IdTipoMovimiento="1" Fecha="2024-04-01" Monto="3" PostByUser="Franco" PostInIP="101.130.170.208" PostTime="2024-04-01 13:07:38"/>
	<movimiento ValorDocId="6431803" IdTipoMovimiento="3" Fecha="2024-05-01" Monto="1" PostByUser="Daniel" PostInIP="209.130.90.28" PostTime="2024-05-01 11:01:06"/>
	<movimiento ValorDocId="6431803" IdTipoMovimiento="4" Fecha="2024-06-01" Monto="3" PostByUser="Alejandro" PostInIP="73.11.208.20" PostTime="2024-06-01 16:31:41"/>
	<movimiento ValorDocId="6431803" IdTipoMovimiento="2" Fecha="2024-07-01" Monto="1" PostByUser="Axel" PostInIP="163.187.130.63" PostTime="2024-07-01 12:27:01"/>
	<movimiento ValorDocId="6431803" IdTipoMovimiento="2" Fecha="2024-08-01" Monto="1" PostByUser="Arturo" PostInIP="177.109.158.192" PostTime="2024-08-01 14:14:57"/>
	<movimiento ValorDocId="6431803" IdTipoMovimiento="1" Fecha="2024-09-01" Monto="1" PostByUser="Axel" PostInIP="162.58.220.119" PostTime="2024-09-01 14:42:00"/>
	<movimiento ValorDocId="6431803" IdTipoMovimiento="2" Fecha="2024-10-01" Monto="3" PostByUser="Franco" PostInIP="73.54.134.204" PostTime="2024-10-01 14:32:21"/>
	<movimiento ValorDocId="4011255" IdTipoMovimiento="5" Fecha="2024-01-01" Monto="2" PostByUser="Franco" PostInIP="58.239.36.218" PostTime="2024-01-01 12:58:26"/>
	<movimiento ValorDocId="4011255" IdTipoMovimiento="1" Fecha="2024-02-01" Monto="1" PostByUser="Axel" PostInIP="73.225.220.91" PostTime="2024-02-01 09:23:28"/>
	<movimiento ValorDocId="4011255" IdTipoMovimiento="1" Fecha="2024-03-01" Monto="2" PostByUser="UsuarioScripts" PostInIP="137.59.255.233" PostTime="2024-03-01 15:42:34"/>
	<movimiento ValorDocId="4011255" IdTipoMovimiento="6" Fecha="2024-04-01" Monto="1" PostByUser="Daniel" PostInIP="19.90.26.93" PostTime="2024-04-01 15:27:51"/>
	<movimiento ValorDocId="4011255" IdTipoMovimiento="2" Fecha="2024-05-01" Monto="1" PostByUser="UsuarioScripts" PostInIP="36.202.170.150" PostTime="2024-05-01 10:51:09"/>
	<movimiento ValorDocId="4011255" IdTipoMovimiento="4" Fecha="2024-06-01" Monto="3" PostByUser="Franco" PostInIP="176.183.186.165" PostTime="2024-06-01 08:20:54"/>
	<movimiento ValorDocId="4011255" IdTipoMovimiento="4" Fecha="2024-07-01" Monto="2" PostByUser="Alejandro" PostInIP="86.173.79.131" PostTime="2024-07-01 14:35:34"/>
	<movimiento ValorDocId="4011255" IdTipoMovimiento="4" Fecha="2024-08-01" Monto="2" PostByUser="Axel" PostInIP="87.24.54.85" PostTime="2024-08-01 13:27:05"/>
	<movimiento ValorDocId="4011255" IdTipoMovimiento="2" Fecha="2024-09-01" Monto="1" PostByUser="Franco" PostInIP="45.143.34.83" PostTime="2024-09-01 15:46:48"/>
	<movimiento ValorDocId="4011255" IdTipoMovimiento="5" Fecha="2024-10-01" Monto="3" PostByUser="UsuarioScripts" PostInIP="53.55.253.0" PostTime="2024-10-01 13:17:34"/>
	<movimiento ValorDocId="3038513" IdTipoMovimiento="3" Fecha="2024-01-01" Monto="2" PostByUser="Alejandro" PostInIP="53.56.73.202" PostTime="2024-01-01 16:50:19"/>
	<movimiento ValorDocId="3038513" IdTipoMovimiento="6" Fecha="2024-02-01" Monto="3" PostByUser="Alejandro" PostInIP="111.143.113.145" PostTime="2024-02-01 10:21:04"/>
	<movimiento ValorDocId="3038513" IdTipoMovimiento="1" Fecha="2024-03-01" Monto="2" PostByUser="Franco" PostInIP="205.91.77.207" PostTime="2024-03-01 15:50:28"/>
	<movimiento ValorDocId="3038513" IdTipoMovimiento="6" Fecha="2024-04-01" Monto="3" PostByUser="Daniel" PostInIP="2.135.43.235" PostTime="2024-04-01 11:27:14"/>
	<movimiento ValorDocId="3038513" IdTipoMovimiento="6" Fecha="2024-05-01" Monto="1" PostByUser="Alejandro" PostInIP="60.112.25.6" PostTime="2024-05-01 15:20:27"/>
	<movimiento ValorDocId="3038513" IdTipoMovimiento="4" Fecha="2024-06-01" Monto="1" PostByUser="UsuarioScripts" PostInIP="108.25.76.236" PostTime="2024-06-01 13:46:43"/>
	<movimiento ValorDocId="3038513" IdTipoMovimiento="2" Fecha="2024-07-01" Monto="1" PostByUser="Axel" PostInIP="73.227.47.213" PostTime="2024-07-01 11:42:02"/>
	<movimiento ValorDocId="3038513" IdTipoMovimiento="2" Fecha="2024-08-01" Monto="2" PostByUser="Daniel" PostInIP="3.2.237.90" PostTime="2024-08-01 18:00:12"/>
	<movimiento ValorDocId="3038513" IdTipoMovimiento="1" Fecha="2024-09-01" Monto="2" PostByUser="Axel" PostInIP="206.11.153.186" PostTime="2024-09-01 14:32:41"/>
	<movimiento ValorDocId="3038513" IdTipoMovimiento="2" Fecha="2024-10-01" Monto="1" PostByUser="Axel" PostInIP="32.37.109.183" PostTime="2024-10-01 13:20:53"/>
	<movimiento ValorDocId="4382196" IdTipoMovimiento="3" Fecha="2024-01-01" Monto="2" PostByUser="Arturo" PostInIP="13.229.136.150" PostTime="2024-01-01 11:59:29"/>
	<movimiento ValorDocId="4382196" IdTipoMovimiento="1" Fecha="2024-02-01" Monto="1" PostByUser="Arturo" PostInIP="182.121.190.156" PostTime="2024-02-01 17:53:14"/>
	<movimiento ValorDocId="4382196" IdTipoMovimiento="4" Fecha="2024-03-01" Monto="3" PostByUser="Arturo" PostInIP="38.249.160.253" PostTime="2024-03-01 08:45:53"/>
	<movimiento ValorDocId="4382196" IdTipoMovimiento="4" Fecha="2024-04-01" Monto="1" PostByUser="Arturo" PostInIP="138.222.210.98" PostTime="2024-04-01 15:33:42"/>
	<movimiento ValorDocId="4382196" IdTipoMovimiento="3" Fecha="2024-05-01" Monto="3" PostByUser="Arturo" PostInIP="21.233.69.146" PostTime="2024-05-01 13:01:06"/>
	<movimiento ValorDocId="4382196" IdTipoMovimiento="2" Fecha="2024-06-01" Monto="1" PostByUser="UsuarioScripts" PostInIP="70.250.243.194" PostTime="2024-06-01 09:21:38"/>
	<movimiento ValorDocId="4382196" IdTipoMovimiento="4" Fecha="2024-07-01" Monto="3" PostByUser="Alejandro" PostInIP="166.152.152.3" PostTime="2024-07-01 18:32:22"/>
	<movimiento ValorDocId="4382196" IdTipoMovimiento="2" Fecha="2024-08-01" Monto="2" PostByUser="UsuarioScripts" PostInIP="104.186.31.137" PostTime="2024-08-01 14:12:28"/>
	<movimiento ValorDocId="4382196" IdTipoMovimiento="2" Fecha="2024-09-01" Monto="1" PostByUser="Arturo" PostInIP="19.223.202.4" PostTime="2024-09-01 18:11:35"/>
	<movimiento ValorDocId="4382196" IdTipoMovimiento="3" Fecha="2024-10-01" Monto="1" PostByUser="UsuarioScripts" PostInIP="50.71.104.223" PostTime="2024-10-01 18:17:09"/>
	<movimiento ValorDocId="2342953" IdTipoMovimiento="3" Fecha="2024-01-01" Monto="1" PostByUser="Daniel" PostInIP="78.105.29.25" PostTime="2024-01-01 17:48:30"/>
	<movimiento ValorDocId="2342953" IdTipoMovimiento="1" Fecha="2024-02-01" Monto="2" PostByUser="Alejandro" PostInIP="162.210.52.159" PostTime="2024-02-01 15:21:51"/>
	<movimiento ValorDocId="2342953" IdTipoMovimiento="1" Fecha="2024-03-01" Monto="2" PostByUser="Axel" PostInIP="155.81.136.193" PostTime="2024-03-01 16:42:35"/>
	<movimiento ValorDocId="2342953" IdTipoMovimiento="1" Fecha="2024-04-01" Monto="3" PostByUser="Alejandro" PostInIP="107.231.27.90" PostTime="2024-04-01 17:45:49"/>
	<movimiento ValorDocId="2342953" IdTipoMovimiento="2" Fecha="2024-05-01" Monto="1" PostByUser="UsuarioScripts" PostInIP="165.6.64.165" PostTime="2024-05-01 17:11:49"/>
	<movimiento ValorDocId="2342953" IdTipoMovimiento="2" Fecha="2024-06-01" Monto="2" PostByUser="Axel" PostInIP="144.218.128.213" PostTime="2024-06-01 12:28:29"/>
	<movimiento ValorDocId="2342953" IdTipoMovimiento="1" Fecha="2024-07-01" Monto="1" PostByUser="Axel" PostInIP="100.227.248.97" PostTime="2024-07-01 16:04:36"/>
	<movimiento ValorDocId="2342953" IdTipoMovimiento="5" Fecha="2024-08-01" Monto="1" PostByUser="Alejandro" PostInIP="50.170.185.230" PostTime="2024-08-01 11:37:27"/>
	<movimiento ValorDocId="2342953" IdTipoMovimiento="3" Fecha="2024-09-01" Monto="3" PostByUser="UsuarioScripts" PostInIP="195.187.173.105" PostTime="2024-09-01 17:06:35"/>
	<movimiento ValorDocId="2342953" IdTipoMovimiento="2" Fecha="2024-10-01" Monto="3" PostByUser="Axel" PostInIP="31.136.74.127" PostTime="2024-10-01 12:08:08"/>
	<movimiento ValorDocId="5836798" IdTipoMovimiento="4" Fecha="2024-01-01" Monto="3" PostByUser="Axel" PostInIP="197.229.213.31" PostTime="2024-01-01 11:48:57"/>
	<movimiento ValorDocId="5836798" IdTipoMovimiento="4" Fecha="2024-02-01" Monto="1" PostByUser="Arturo" PostInIP="17.121.34.115" PostTime="2024-02-01 14:57:23"/>
	<movimiento ValorDocId="5836798" IdTipoMovimiento="1" Fecha="2024-03-01" Monto="2" PostByUser="Arturo" PostInIP="44.35.135.198" PostTime="2024-03-01 15:59:48"/>
	<movimiento ValorDocId="5836798" IdTipoMovimiento="6" Fecha="2024-04-01" Monto="2" PostByUser="Axel" PostInIP="198.57.59.124" PostTime="2024-04-01 15:46:47"/>
	<movimiento ValorDocId="5836798" IdTipoMovimiento="2" Fecha="2024-05-01" Monto="1" PostByUser="Franco" PostInIP="214.173.72.90" PostTime="2024-05-01 09:58:15"/>
	<movimiento ValorDocId="5836798" IdTipoMovimiento="4" Fecha="2024-06-01" Monto="1" PostByUser="Daniel" PostInIP="106.206.73.232" PostTime="2024-06-01 17:41:32"/>
	<movimiento ValorDocId="5836798" IdTipoMovimiento="1" Fecha="2024-07-01" Monto="3" PostByUser="Alejandro" PostInIP="134.134.213.195" PostTime="2024-07-01 12:31:00"/>
	<movimiento ValorDocId="5836798" IdTipoMovimiento="6" Fecha="2024-08-01" Monto="2" PostByUser="Franco" PostInIP="67.193.176.234" PostTime="2024-08-01 12:30:06"/>
	<movimiento ValorDocId="5836798" IdTipoMovimiento="3" Fecha="2024-09-01" Monto="2" PostByUser="Arturo" PostInIP="122.99.128.20" PostTime="2024-09-01 16:44:00"/>
	<movimiento ValorDocId="5836798" IdTipoMovimiento="1" Fecha="2024-10-01" Monto="3" PostByUser="Axel" PostInIP="202.6.164.82" PostTime="2024-10-01 13:08:10"/>
	<movimiento ValorDocId="1053434" IdTipoMovimiento="2" Fecha="2024-01-01" Monto="3" PostByUser="Alejandro" PostInIP="23.49.50.78" PostTime="2024-01-01 14:58:32"/>
	<movimiento ValorDocId="1053434" IdTipoMovimiento="6" Fecha="2024-02-01" Monto="1" PostByUser="Franco" PostInIP="37.246.4.140" PostTime="2024-02-01 17:05:22"/>
	<movimiento ValorDocId="1053434" IdTipoMovimiento="4" Fecha="2024-03-01" Monto="3" PostByUser="UsuarioScripts" PostInIP="90.93.68.133" PostTime="2024-03-01 17:36:48"/>
	<movimiento ValorDocId="1053434" IdTipoMovimiento="4" Fecha="2024-04-01" Monto="1" PostByUser="Axel" PostInIP="92.100.68.172" PostTime="2024-04-01 09:54:45"/>
	<movimiento ValorDocId="1053434" IdTipoMovimiento="5" Fecha="2024-05-01" Monto="1" PostByUser="UsuarioScripts" PostInIP="193.37.157.0" PostTime="2024-05-01 18:10:20"/>
	<movimiento ValorDocId="1053434" IdTipoMovimiento="1" Fecha="2024-06-01" Monto="1" PostByUser="Arturo" PostInIP="41.251.196.245" PostTime="2024-06-01 16:52:44"/>
	<movimiento ValorDocId="1053434" IdTipoMovimiento="6" Fecha="2024-07-01" Monto="3" PostByUser="Axel" PostInIP="31.6.164.29" PostTime="2024-07-01 11:41:40"/>
	<movimiento ValorDocId="1053434" IdTipoMovimiento="5" Fecha="2024-08-01" Monto="1" PostByUser="Axel" PostInIP="180.153.124.69" PostTime="2024-08-01 14:09:42"/>
	<movimiento ValorDocId="1053434" IdTipoMovimiento="3" Fecha="2024-09-01" Monto="3" PostByUser="Franco" PostInIP="152.4.158.39" PostTime="2024-09-01 12:43:50"/>
	<movimiento ValorDocId="1053434" IdTipoMovimiento="1" Fecha="2024-10-01" Monto="1" PostByUser="Alejandro" PostInIP="169.105.43.106" PostTime="2024-10-01 13:29:06"/>
	<movimiento ValorDocId="5433860" IdTipoMovimiento="3" Fecha="2024-01-01" Monto="1" PostByUser="Arturo" PostInIP="169.237.215.157" PostTime="2024-01-01 12:23:47"/>
	<movimiento ValorDocId="5433860" IdTipoMovimiento="1" Fecha="2024-02-01" Monto="2" PostByUser="Alejandro" PostInIP="150.219.236.34" PostTime="2024-02-01 18:00:28"/>
	<movimiento ValorDocId="5433860" IdTipoMovimiento="4" Fecha="2024-03-01" Monto="3" PostByUser="Daniel" PostInIP="142.106.83.159" PostTime="2024-03-01 15:00:32"/>
	<movimiento ValorDocId="5433860" IdTipoMovimiento="1" Fecha="2024-04-01" Monto="1" PostByUser="Daniel" PostInIP="32.226.228.111" PostTime="2024-04-01 17:48:06"/>
	<movimiento ValorDocId="5433860" IdTipoMovimiento="4" Fecha="2024-05-01" Monto="2" PostByUser="UsuarioScripts" PostInIP="19.202.188.148" PostTime="2024-05-01 18:23:47"/>
	<movimiento ValorDocId="5433860" IdTipoMovimiento="4" Fecha="2024-06-01" Monto="1" PostByUser="Daniel" PostInIP="203.250.93.85" PostTime="2024-06-01 13:26:04"/>
	<movimiento ValorDocId="5433860" IdTipoMovimiento="3" Fecha="2024-07-01" Monto="3" PostByUser="Axel" PostInIP="219.198.78.15" PostTime="2024-07-01 08:39:33"/>
	<movimiento ValorDocId="5433860" IdTipoMovimiento="3" Fecha="2024-08-01" Monto="1" PostByUser="Arturo" PostInIP="81.125.153.235" PostTime="2024-08-01 14:34:42"/>
	<movimiento ValorDocId="5433860" IdTipoMovimiento="1" Fecha="2024-09-01" Monto="2" PostByUser="Daniel" PostInIP="76.245.104.216" PostTime="2024-09-01 12:50:58"/>
	<movimiento ValorDocId="5433860" IdTipoMovimiento="3" Fecha="2024-10-01" Monto="3" PostByUser="Alejandro" PostInIP="89.194.189.87" PostTime="2024-10-01 08:31:51"/>
	<movimiento ValorDocId="7991371" IdTipoMovimiento="2" Fecha="2024-01-01" Monto="1" PostByUser="Franco" PostInIP="159.165.69.131" PostTime="2024-01-01 12:57:45"/>
	<movimiento ValorDocId="7991371" IdTipoMovimiento="2" Fecha="2024-02-01" Monto="3" PostByUser="Axel" PostInIP="143.91.3.241" PostTime="2024-02-01 09:51:55"/>
	<movimiento ValorDocId="7991371" IdTipoMovimiento="1" Fecha="2024-03-01" Monto="3" PostByUser="Arturo" PostInIP="189.174.173.111" PostTime="2024-03-01 16:17:54"/>
	<movimiento ValorDocId="7991371" IdTipoMovimiento="6" Fecha="2024-04-01" Monto="2" PostByUser="UsuarioScripts" PostInIP="71.201.94.177" PostTime="2024-04-01 14:51:32"/>
	<movimiento ValorDocId="7991371" IdTipoMovimiento="4" Fecha="2024-05-01" Monto="2" PostByUser="UsuarioScripts" PostInIP="107.188.143.77" PostTime="2024-05-01 08:59:06"/>
	<movimiento ValorDocId="7991371" IdTipoMovimiento="1" Fecha="2024-06-01" Monto="3" PostByUser="Axel" PostInIP="214.6.85.33" PostTime="2024-06-01 09:14:48"/>
	<movimiento ValorDocId="7991371" IdTipoMovimiento="2" Fecha="2024-07-01" Monto="1" PostByUser="Axel" PostInIP="176.105.11.19" PostTime="2024-07-01 11:12:41"/>
	<movimiento ValorDocId="7991371" IdTipoMovimiento="2" Fecha="2024-08-01" Monto="2" PostByUser="Axel" PostInIP="99.147.36.18" PostTime="2024-08-01 13:04:15"/>
	<movimiento ValorDocId="7991371" IdTipoMovimiento="1" Fecha="2024-09-01" Monto="2" PostByUser="Alejandro" PostInIP="53.50.94.179" PostTime="2024-09-01 09:29:12"/>
	<movimiento ValorDocId="7991371" IdTipoMovimiento="3" Fecha="2024-10-01" Monto="3" PostByUser="Franco" PostInIP="1.215.33.238" PostTime="2024-10-01 18:52:48"/>
	<movimiento ValorDocId="6544296" IdTipoMovimiento="2" Fecha="2024-01-01" Monto="2" PostByUser="UsuarioScripts" PostInIP="125.161.224.78" PostTime="2024-01-01 11:58:52"/>
	<movimiento ValorDocId="6544296" IdTipoMovimiento="4" Fecha="2024-02-01" Monto="2" PostByUser="Daniel" PostInIP="70.53.210.218" PostTime="2024-02-01 12:29:15"/>
	<movimiento ValorDocId="6544296" IdTipoMovimiento="4" Fecha="2024-03-01" Monto="2" PostByUser="Daniel" PostInIP="32.190.129.127" PostTime="2024-03-01 12:48:46"/>
	<movimiento ValorDocId="6544296" IdTipoMovimiento="5" Fecha="2024-04-01" Monto="2" PostByUser="Franco" PostInIP="35.32.62.7" PostTime="2024-04-01 16:40:05"/>
	<movimiento ValorDocId="6544296" IdTipoMovimiento="1" Fecha="2024-05-01" Monto="2" PostByUser="UsuarioScripts" PostInIP="19.83.135.212" PostTime="2024-05-01 12:51:17"/>
	<movimiento ValorDocId="6544296" IdTipoMovimiento="5" Fecha="2024-06-01" Monto="2" PostByUser="Axel" PostInIP="167.38.219.196" PostTime="2024-06-01 10:32:51"/>
	<movimiento ValorDocId="6544296" IdTipoMovimiento="6" Fecha="2024-07-01" Monto="3" PostByUser="Franco" PostInIP="20.52.227.16" PostTime="2024-07-01 15:41:57"/>
	<movimiento ValorDocId="6544296" IdTipoMovimiento="3" Fecha="2024-08-01" Monto="1" PostByUser="Franco" PostInIP="210.188.107.151" PostTime="2024-08-01 12:16:50"/>
	<movimiento ValorDocId="6544296" IdTipoMovimiento="4" Fecha="2024-09-01" Monto="1" PostByUser="Daniel" PostInIP="106.121.130.216" PostTime="2024-09-01 16:33:20"/>
	<movimiento ValorDocId="6544296" IdTipoMovimiento="4" Fecha="2024-10-01" Monto="2" PostByUser="Arturo" PostInIP="30.7.11.135" PostTime="2024-10-01 13:37:10"/>
	<movimiento ValorDocId="5176529" IdTipoMovimiento="2" Fecha="2024-01-01" Monto="1" PostByUser="Alejandro" PostInIP="84.93.198.132" PostTime="2024-01-01 09:23:12"/>
	<movimiento ValorDocId="5176529" IdTipoMovimiento="2" Fecha="2024-02-01" Monto="2" PostByUser="Daniel" PostInIP="218.116.160.134" PostTime="2024-02-01 10:59:22"/>
	<movimiento ValorDocId="5176529" IdTipoMovimiento="1" Fecha="2024-03-01" Monto="2" PostByUser="Axel" PostInIP="175.78.99.32" PostTime="2024-03-01 17:22:54"/>
	<movimiento ValorDocId="5176529" IdTipoMovimiento="6" Fecha="2024-04-01" Monto="1" PostByUser="Daniel" PostInIP="3.244.70.252" PostTime="2024-04-01 18:01:31"/>
	<movimiento ValorDocId="5176529" IdTipoMovimiento="6" Fecha="2024-05-01" Monto="3" PostByUser="Franco" PostInIP="122.149.203.233" PostTime="2024-05-01 09:10:54"/>
	<movimiento ValorDocId="5176529" IdTipoMovimiento="3" Fecha="2024-06-01" Monto="3" PostByUser="Arturo" PostInIP="43.124.138.5" PostTime="2024-06-01 18:53:46"/>
	<movimiento ValorDocId="5176529" IdTipoMovimiento="6" Fecha="2024-07-01" Monto="3" PostByUser="Alejandro" PostInIP="191.165.175.90" PostTime="2024-07-01 11:19:51"/>
	<movimiento ValorDocId="5176529" IdTipoMovimiento="2" Fecha="2024-08-01" Monto="3" PostByUser="Franco" PostInIP="18.217.12.7" PostTime="2024-08-01 10:48:05"/>
	<movimiento ValorDocId="5176529" IdTipoMovimiento="3" Fecha="2024-09-01" Monto="1" PostByUser="UsuarioScripts" PostInIP="52.125.159.170" PostTime="2024-09-01 10:51:36"/>
	<movimiento ValorDocId="5176529" IdTipoMovimiento="2" Fecha="2024-10-01" Monto="1" PostByUser="UsuarioScripts" PostInIP="167.184.203.104" PostTime="2024-10-01 16:11:21"/>
	<movimiento ValorDocId="2135917" IdTipoMovimiento="6" Fecha="2024-01-01" Monto="3" PostByUser="Daniel" PostInIP="51.212.149.112" PostTime="2024-01-01 13:52:05"/>
	<movimiento ValorDocId="2135917" IdTipoMovimiento="1" Fecha="2024-02-01" Monto="1" PostByUser="Axel" PostInIP="150.152.240.199" PostTime="2024-02-01 12:24:08"/>
	<movimiento ValorDocId="2135917" IdTipoMovimiento="4" Fecha="2024-03-01" Monto="2" PostByUser="Franco" PostInIP="149.173.163.73" PostTime="2024-03-01 14:54:16"/>
	<movimiento ValorDocId="2135917" IdTipoMovimiento="4" Fecha="2024-04-01" Monto="1" PostByUser="Arturo" PostInIP="93.82.70.75" PostTime="2024-04-01 09:43:25"/>
	<movimiento ValorDocId="2135917" IdTipoMovimiento="5" Fecha="2024-05-01" Monto="1" PostByUser="Alejandro" PostInIP="222.180.148.211" PostTime="2024-05-01 14:45:24"/>
	<movimiento ValorDocId="2135917" IdTipoMovimiento="1" Fecha="2024-06-01" Monto="1" PostByUser="Axel" PostInIP="167.54.232.232" PostTime="2024-06-01 12:39:17"/>
	<movimiento ValorDocId="2135917" IdTipoMovimiento="3" Fecha="2024-07-01" Monto="1" PostByUser="Arturo" PostInIP="182.135.77.224" PostTime="2024-07-01 14:49:27"/>
	<movimiento ValorDocId="2135917" IdTipoMovimiento="4" Fecha="2024-08-01" Monto="1" PostByUser="UsuarioScripts" PostInIP="47.131.29.45" PostTime="2024-08-01 08:50:40"/>
	<movimiento ValorDocId="2135917" IdTipoMovimiento="3" Fecha="2024-09-01" Monto="3" PostByUser="Franco" PostInIP="167.89.104.71" PostTime="2024-09-01 15:53:30"/>
	<movimiento ValorDocId="2135917" IdTipoMovimiento="2" Fecha="2024-10-01" Monto="1" PostByUser="Daniel" PostInIP="58.10.15.159" PostTime="2024-10-01 12:39:24"/>
	<movimiento ValorDocId="4387142" IdTipoMovimiento="5" Fecha="2024-01-01" Monto="3" PostByUser="Axel" PostInIP="200.99.130.252" PostTime="2024-01-01 12:06:55"/>
	<movimiento ValorDocId="4387142" IdTipoMovimiento="6" Fecha="2024-02-01" Monto="2" PostByUser="Axel" PostInIP="165.164.160.199" PostTime="2024-02-01 09:21:54"/>
	<movimiento ValorDocId="4387142" IdTipoMovimiento="5" Fecha="2024-03-01" Monto="1" PostByUser="Daniel" PostInIP="190.2.9.190" PostTime="2024-03-01 10:47:25"/>
	<movimiento ValorDocId="4387142" IdTipoMovimiento="6" Fecha="2024-04-01" Monto="1" PostByUser="Alejandro" PostInIP="168.11.131.132" PostTime="2024-04-01 18:08:22"/>
	<movimiento ValorDocId="4387142" IdTipoMovimiento="1" Fecha="2024-05-01" Monto="1" PostByUser="Daniel" PostInIP="194.248.161.117" PostTime="2024-05-01 09:57:19"/>
	<movimiento ValorDocId="4387142" IdTipoMovimiento="3" Fecha="2024-06-01" Monto="1" PostByUser="Franco" PostInIP="137.41.139.237" PostTime="2024-06-01 18:50:58"/>
	<movimiento ValorDocId="4387142" IdTipoMovimiento="5" Fecha="2024-07-01" Monto="1" PostByUser="Alejandro" PostInIP="32.3.53.163" PostTime="2024-07-01 13:36:10"/>
	<movimiento ValorDocId="4387142" IdTipoMovimiento="6" Fecha="2024-08-01" Monto="1" PostByUser="Alejandro" PostInIP="96.53.10.142" PostTime="2024-08-01 16:30:09"/>
	<movimiento ValorDocId="4387142" IdTipoMovimiento="2" Fecha="2024-09-01" Monto="3" PostByUser="Daniel" PostInIP="57.93.68.184" PostTime="2024-09-01 13:12:47"/>
	<movimiento ValorDocId="4387142" IdTipoMovimiento="5" Fecha="2024-10-01" Monto="3" PostByUser="UsuarioScripts" PostInIP="199.92.70.190" PostTime="2024-10-01 14:02:01"/>
	<movimiento ValorDocId="5904068" IdTipoMovimiento="5" Fecha="2024-01-01" Monto="1" PostByUser="Arturo" PostInIP="103.83.92.68" PostTime="2024-01-01 18:17:50"/>
	<movimiento ValorDocId="5904068" IdTipoMovimiento="4" Fecha="2024-02-01" Monto="3" PostByUser="Alejandro" PostInIP="53.216.21.191" PostTime="2024-02-01 12:57:19"/>
	<movimiento ValorDocId="5904068" IdTipoMovimiento="1" Fecha="2024-03-01" Monto="2" PostByUser="Franco" PostInIP="47.171.119.167" PostTime="2024-03-01 11:14:11"/>
	<movimiento ValorDocId="5904068" IdTipoMovimiento="3" Fecha="2024-04-01" Monto="1" PostByUser="Daniel" PostInIP="167.120.118.14" PostTime="2024-04-01 10:20:28"/>
	<movimiento ValorDocId="5904068" IdTipoMovimiento="6" Fecha="2024-05-01" Monto="3" PostByUser="Franco" PostInIP="208.19.95.176" PostTime="2024-05-01 16:03:46"/>
	<movimiento ValorDocId="5904068" IdTipoMovimiento="1" Fecha="2024-06-01" Monto="1" PostByUser="UsuarioScripts" PostInIP="115.181.92.19" PostTime="2024-06-01 17:51:39"/>
	<movimiento ValorDocId="5904068" IdTipoMovimiento="5" Fecha="2024-07-01" Monto="3" PostByUser="Alejandro" PostInIP="167.24.15.76" PostTime="2024-07-01 15:32:00"/>
	<movimiento ValorDocId="5904068" IdTipoMovimiento="6" Fecha="2024-08-01" Monto="1" PostByUser="Franco" PostInIP="177.79.249.147" PostTime="2024-08-01 08:05:36"/>
	<movimiento ValorDocId="5904068" IdTipoMovimiento="5" Fecha="2024-09-01" Monto="1" PostByUser="Arturo" PostInIP="207.187.99.149" PostTime="2024-09-01 18:03:25"/>
	<movimiento ValorDocId="5904068" IdTipoMovimiento="1" Fecha="2024-10-01" Monto="3" PostByUser="Axel" PostInIP="93.215.181.247" PostTime="2024-10-01 12:21:07"/>
	<movimiento ValorDocId="5361005" IdTipoMovimiento="3" Fecha="2024-01-01" Monto="3" PostByUser="UsuarioScripts" PostInIP="13.164.75.116" PostTime="2024-01-01 11:50:02"/>
	<movimiento ValorDocId="5361005" IdTipoMovimiento="1" Fecha="2024-02-01" Monto="3" PostByUser="Franco" PostInIP="148.158.56.85" PostTime="2024-02-01 18:26:50"/>
	<movimiento ValorDocId="5361005" IdTipoMovimiento="6" Fecha="2024-03-01" Monto="1" PostByUser="UsuarioScripts" PostInIP="74.37.193.172" PostTime="2024-03-01 17:03:59"/>
	<movimiento ValorDocId="5361005" IdTipoMovimiento="5" Fecha="2024-04-01" Monto="3" PostByUser="Franco" PostInIP="71.216.230.156" PostTime="2024-04-01 18:01:28"/>
	<movimiento ValorDocId="5361005" IdTipoMovimiento="3" Fecha="2024-05-01" Monto="3" PostByUser="Alejandro" PostInIP="179.217.34.96" PostTime="2024-05-01 17:11:50"/>
	<movimiento ValorDocId="5361005" IdTipoMovimiento="6" Fecha="2024-06-01" Monto="3" PostByUser="UsuarioScripts" PostInIP="59.208.153.182" PostTime="2024-06-01 15:55:47"/>
	<movimiento ValorDocId="5361005" IdTipoMovimiento="3" Fecha="2024-07-01" Monto="2" PostByUser="UsuarioScripts" PostInIP="149.65.161.53" PostTime="2024-07-01 15:47:47"/>
	<movimiento ValorDocId="5361005" IdTipoMovimiento="1" Fecha="2024-08-01" Monto="3" PostByUser="Daniel" PostInIP="187.43.122.8" PostTime="2024-08-01 16:36:16"/>
	<movimiento ValorDocId="5361005" IdTipoMovimiento="2" Fecha="2024-09-01" Monto="3" PostByUser="Alejandro" PostInIP="101.44.4.41" PostTime="2024-09-01 09:09:46"/>
	<movimiento ValorDocId="5361005" IdTipoMovimiento="4" Fecha="2024-10-01" Monto="1" PostByUser="UsuarioScripts" PostInIP="60.115.205.229" PostTime="2024-10-01 18:31:22"/>
	<movimiento ValorDocId="2804664" IdTipoMovimiento="3" Fecha="2024-01-01" Monto="2" PostByUser="Daniel" PostInIP="102.163.123.144" PostTime="2024-01-01 15:18:23"/>
	<movimiento ValorDocId="2804664" IdTipoMovimiento="2" Fecha="2024-02-01" Monto="1" PostByUser="Arturo" PostInIP="151.207.191.115" PostTime="2024-02-01 10:46:55"/>
	<movimiento ValorDocId="2804664" IdTipoMovimiento="3" Fecha="2024-03-01" Monto="2" PostByUser="UsuarioScripts" PostInIP="71.244.216.153" PostTime="2024-03-01 10:48:43"/>
	<movimiento ValorDocId="2804664" IdTipoMovimiento="2" Fecha="2024-04-01" Monto="2" PostByUser="Daniel" PostInIP="197.25.133.119" PostTime="2024-04-01 14:44:08"/>
	<movimiento ValorDocId="2804664" IdTipoMovimiento="4" Fecha="2024-05-01" Monto="2" PostByUser="UsuarioScripts" PostInIP="78.59.194.80" PostTime="2024-05-01 16:34:39"/>
	<movimiento ValorDocId="2804664" IdTipoMovimiento="6" Fecha="2024-06-01" Monto="1" PostByUser="UsuarioScripts" PostInIP="15.166.46.176" PostTime="2024-06-01 09:45:27"/>
	<movimiento ValorDocId="2804664" IdTipoMovimiento="3" Fecha="2024-07-01" Monto="3" PostByUser="UsuarioScripts" PostInIP="184.125.237.18" PostTime="2024-07-01 14:45:17"/>
	<movimiento ValorDocId="2804664" IdTipoMovimiento="1" Fecha="2024-08-01" Monto="3" PostByUser="Axel" PostInIP="125.84.147.220" PostTime="2024-08-01 18:58:08"/>
	<movimiento ValorDocId="2804664" IdTipoMovimiento="6" Fecha="2024-09-01" Monto="3" PostByUser="Daniel" PostInIP="165.63.197.166" PostTime="2024-09-01 09:47:36"/>
	<movimiento ValorDocId="2804664" IdTipoMovimiento="5" Fecha="2024-10-01" Monto="3" PostByUser="Franco" PostInIP="208.213.229.41" PostTime="2024-10-01 16:53:21"/>
	<movimiento ValorDocId="5612560" IdTipoMovimiento="1" Fecha="2024-01-01" Monto="1" PostByUser="Alejandro" PostInIP="183.198.58.143" PostTime="2024-01-01 08:13:52"/>
	<movimiento ValorDocId="5612560" IdTipoMovimiento="2" Fecha="2024-02-01" Monto="3" PostByUser="Axel" PostInIP="75.4.5.158" PostTime="2024-02-01 12:43:15"/>
	<movimiento ValorDocId="5612560" IdTipoMovimiento="6" Fecha="2024-03-01" Monto="2" PostByUser="UsuarioScripts" PostInIP="187.148.251.63" PostTime="2024-03-01 16:56:26"/>
	<movimiento ValorDocId="5612560" IdTipoMovimiento="2" Fecha="2024-04-01" Monto="3" PostByUser="Arturo" PostInIP="190.91.189.44" PostTime="2024-04-01 13:44:37"/>
	<movimiento ValorDocId="5612560" IdTipoMovimiento="1" Fecha="2024-05-01" Monto="1" PostByUser="Daniel" PostInIP="17.44.164.189" PostTime="2024-05-01 14:47:09"/>
	<movimiento ValorDocId="5612560" IdTipoMovimiento="2" Fecha="2024-06-01" Monto="3" PostByUser="Arturo" PostInIP="132.130.89.197" PostTime="2024-06-01 18:49:52"/>
	<movimiento ValorDocId="5612560" IdTipoMovimiento="2" Fecha="2024-07-01" Monto="3" PostByUser="Daniel" PostInIP="1.47.53.53" PostTime="2024-07-01 08:26:40"/>
	<movimiento ValorDocId="5612560" IdTipoMovimiento="2" Fecha="2024-08-01" Monto="2" PostByUser="Arturo" PostInIP="163.127.226.141" PostTime="2024-08-01 11:04:04"/>
	<movimiento ValorDocId="5612560" IdTipoMovimiento="4" Fecha="2024-09-01" Monto="3" PostByUser="Alejandro" PostInIP="148.197.132.158" PostTime="2024-09-01 13:11:12"/>
	<movimiento ValorDocId="5612560" IdTipoMovimiento="5" Fecha="2024-10-01" Monto="1" PostByUser="Axel" PostInIP="8.64.217.200" PostTime="2024-10-01 15:29:19"/>
	</Movimientos>
	<Error>
	<error Codigo="50001" Descripcion="Username no existe"/>
	<error Codigo="50002" Descripcion="Password no existe"/>
	<error Codigo="50003" Descripcion="Login deshabilitado"/>
	<error Codigo="50004" Descripcion="Empleado con ValorDocumentoIdentidad ya existe en inserci�n"/>
	<error Codigo="50005" Descripcion="Empleado con mismo nombre ya existe en inserci�n"/>
	<error Codigo="50006" Descripcion="Empleado con ValorDocumentoIdentidad ya existe en actualizacion"/>
	<error Codigo="50007" Descripcion="Empleado con mismo nombre ya existe en actualizaci�n"/>
	<error Codigo="50008" Descripcion="Error de base de datos"/>
	<error Codigo="50009" Descripcion="Nombre de empleado no alfab�tico"/>
	<error Codigo="50010" Descripcion="Valor de documento de identidad no alfab�tico"/>
	<error Codigo="50011" Descripcion="Monto del movimiento rechazado pues si se aplicar el saldo seria negativo."/>
	</Error>
	</Datos>';


--SET IDENTITY_INSERT Puesto ON;

--SET IDENTITY_INSERT TipoEvento ON;
-- Hay que hacerlo asi ya que la DB esta montada en Linux y el comando OPENROWSET no es soportado en Linux MSSQL

--

	DELETE FROM dbo.Puesto
	DELETE FROM dbo.TipoEvento
	DELETE FROM dbo.TipoMovimiento
	DELETE FROM dbo.Empleado 
	DELETE FROM dbo.Usuario
	DELETE FROM dbo.Error
	DELETE FROM dbo.Movimiento

	SET IDENTITY_INSERT Puesto ON;

	INSERT INTO Puesto (Id, Nombre, SalarioxHora)
	SELECT 
		Puesto.value('@Id', 'INT') AS Id,
		Puesto.value('@Nombre', 'NVARCHAR(100)') AS Nombre,
		Puesto.value('@SalarioxHora', 'DECIMAL(10, 2)') AS SalarioxHora
	FROM @xmlData.nodes('/Datos/Puestos/Puesto') AS T(Puesto); --Hay que delimitar el formato
	--Cada valor esta asociado: en su columna, y el tipo
	SET IDENTITY_INSERT Puesto OFF;

	SET IDENTITY_INSERT TipoEvento ON;
	INSERT INTO TipoEvento (Id, Nombre)
	SELECT 
		TipoEvento.value('@Id', 'INT') AS Id,
		TipoEvento.value('@Nombre', 'NVARCHAR(100)') AS Nombre
	FROM @xmlData.nodes('/Datos/TiposEvento/TipoEvento') AS T(TipoEvento);
	SET IDENTITY_INSERT TipoEvento OFF; 



	INSERT INTO Error (Codigo, Descripcion)
		SELECT
			Error.value('@Codigo','INT') AS Codigo,
			Error.value('@Descripcion','VARCHAR(100)') AS Descripcion
	FROM @xmlData.nodes('/Datos/Error/error') AS T(Error);

	SET IDENTITY_INSERT TipoMovimiento ON


SET NOCOUNT OFF
END


