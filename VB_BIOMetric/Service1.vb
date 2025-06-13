Imports System.Configuration
Imports System.Data.SqlClient
Imports System.IO
Imports System.Net
Imports System.Text
Imports System.Timers
Imports Sap.Data.Hana

Public Class Service1
    'Dim logger As Logger = LogManager.GetCurrentClassLogger()

    'Dim _objData As New DataHelper
    Dim TriggerFlag As Integer = 0
    Public TriggerTime As Integer = CInt(System.Configuration.ConfigurationSettings.AppSettings("TriggerTime"))
    Private WithEvents Timer As New Timer()
    Dim HANAConnection As String = ""
    Dim con As HanaConnection
    Dim dsEmployeeList As DataSet
    Dim dsSQLEmployeeData As DataSet
    Dim dsExistData As DataSet
    'Dim logger As Logger = LogManager.GetCurrentClassLogger()

    Protected Overrides Sub OnStart(ByVal args() As String)
        ' Add code here to start your service. This method should set things
        ' in motion so your service can do its work.
        Me.AddToFileIN("------------------------------------------------------------------" + System.DateTime.Now())
        Me.AddToFileIN("Biometric Integration Service is Started")
        TriggerFlag = 0
        'AddHandler Timer.Elapsed, AddressOf OnElapsedTime
        'Timer.Interval = TriggerTime
        'Timer.Enabled = True

        Me.OnElapsedTime()

    End Sub

    Protected Overrides Sub OnStop()
        ' Add code here to perform any tear-down necessary to stop your service.
        Me.AddToFileIN("-----Service Stoped---------------------------------------------" + System.DateTime.Now())
    End Sub

    Friend Sub TestStartupAndStop(ByVal args As String())
        Me.OnStart(args)
        Me.OnElapsedTime()
        Me.OnStop()
    End Sub

    Private Sub OnElapsedTime()
        Try
            Me.AddToFileIN("-----On Elapsed Time-----------------------------------------------" + System.DateTime.Now())
            If TriggerFlag = 0 Then
                TriggerFlag = 1

                Dim DataTable As DataTable
                Dim SourceType As String = ConfigurationSettings.AppSettings.Get("SourceType").ToString()
                If SourceType = "MSACCESS" Then
                    DataTable = Me.GetData()
                    '----------Inserting into hana------------
                    Dim UpdateQry As String = "Update CHECKINOUT Set IsProcessed = 1 Where IsProcessed = 0 or IsProcessed is null "
                    'Dim UpdateQry As String = "Update CHECKINOUT Set IsProcessed = '1' Where CHECKTIME between #01/01/2014# and #01/01/2021# "
                    Me.InsertIntoHana(DataTable, UpdateQry)
                ElseIf SourceType = "SQL" Then

                    'Dim Str As String = "SELECT stg_Emp_Id 'USERID','' 'NAME',stg_PunchDate 'DATE'" & _
                    '              " ,convert(time(0),stg_InPunch)  'IN',convert(time(0),stg_OutPunch) 'OUT' " & _
                    '              " ,'' 'OverTime','' 'Short','' 'Remarks','' 'DayStatus','' 'DayStatus1','' 'DayStatus2' " & _
                    '              " ,'' 'Sync','' 'FileName'  FROM [stg_Att_Data] Where stg_IsProcessed = '0'"

                    'Me.AddToFileIN("------------------------------------------------------------------" + System.DateTime.Now())
                    'DataTable = Me.GetSqlConnection(Str)
                    '----------Inserting into hana------------
                    'Dim UpdateQry As String = "Update [stg_Att_Data] Set stg_IsProcessed='1' Where stg_IsProcessed = '0'"
                    'Me.InsertIntoHana(DataTable, UpdateQry)

                    Me.SQLIntegration()

                ElseIf SourceType = "API" Then
                    Dim DatabaseList As String = ConfigurationSettings.AppSettings.Get("DatabaseList").ToString()
                    Dim ConnectionStringList As String()
                    Dim HANAConnection As String = ""
                    Dim HANADatabase As String = ""
                    If DatabaseList <> "" Then
                        ConnectionStringList = DatabaseList.Split(",")
                        For k As Integer = 0 To ConnectionStringList.Length - 1
                            HANADatabase = ConnectionStringList(k)
                            HANAConnection = ConfigurationSettings.AppSettings(HANADatabase).ToString()
                            Dim Query As String = "SELECT ""ExtEmpNo"",(SELECT ""U_StartDate"" FROM ""@SBO_BIOMETRIC"") AS ""StartDate"",(SELECT ""U_NPDate"" FROM ""@SBO_PRCONTROL"") AS ""EndDate"" " &
                                "FROM OHEM Where ""Active""='Y'"
                            Dim cmd As HanaCommand = New HanaCommand
                            Dim conHana As HanaConnection = New HanaConnection(HANAConnection)
                            conHana.Open()
                            cmd = New HanaCommand(Query, conHana)
                            Dim da As HanaDataAdapter = New HanaDataAdapter(cmd)
                            Dim ds As DataSet = New DataSet()
                            da.Fill(ds)
                            Dim DT As DataTable = Nothing
                            Dim RowsCount As Integer
                            If ds IsNot Nothing Then
                                RowsCount = ds.Tables(0).Rows.Count
                                DT = ds.Tables(0)
                            End If

                            If RowsCount > 0 Then
                                For Each row As DataRow In DT.Rows
                                    Dim ExtEmpNo As String = row(0).ToString()

                                    Dim StartDate1 As Date = row(1).ToString()
                                    Dim EndDate1 As Date = row(2).ToString()

                                    Dim StartDate As String = StartDate1.ToString("ddMMyyyy")
                                    Dim EndDate As String = DateTime.Now.ToString("ddMMyyyy")
                                    Me.UpdateAPIDataInHANA(ExtEmpNo, StartDate, EndDate, HANAConnection)
                                Next
                            End If
                            'Query = "Update ""@SBO_BIOMETRIC"" set ""U_StartDate"" = '" & DateTime.Now.ToString("yyyyMMdd") & "'"
                            Query = "Update ""@SBO_BIOMETRIC"" set ""U_StartDate"" = (SELECT ""U_AS"" FROM ""@SBO_PRCONTROL"") "

                            Dim cmd2 As HanaCommand = New HanaCommand
                            cmd2 = New HanaCommand(Query, conHana)
                            cmd2.ExecuteNonQuery()
                            conHana.Close()
                        Next
                    End If
                End If

                'TriggerFlag = 0
                AddToFileIN("Trigger Updated to 0:" + System.DateTime.Now())
            End If
        Catch ex As Exception
            TriggerFlag = 0
            AddToFileIN("OnElapsed:" & ex.Message)
        Finally
            AddToFileIN("On Elapse Company Object Released")
        End Try
    End Sub

    Public Sub InsertIntoHana(ByVal DataTable As DataTable, ByVal QueryString As String)
        Try
            If DataTable IsNot Nothing AndAlso DataTable.Rows.Count > 0 Then
                Me.AddToFileIN("Found " & DataTable.Rows.Count.ToString & " results" + "--" + System.DateTime.Now())
                Dim cmd As SqlCommand = New SqlCommand
                Dim App_Connection As String = ConfigurationSettings.AppSettings.Get("HANAConnectionString").ToString()
                Dim SourceType As String = ConfigurationSettings.AppSettings.Get("SourceType").ToString()

                Dim conHana As HanaConnection = New HanaConnection(App_Connection)
                conHana.Open()
                Dim bulkCopy As HanaBulkCopy = New HanaBulkCopy(App_Connection, HanaBulkCopyOptions.TableLock)
                bulkCopy.BatchSize = 10000

                If SourceType = "MSACCESS" Then
                    bulkCopy.DestinationTableName = "ATT_BIODATA"
                    Me.UpdateProcessedRecords_MsAccess(QueryString)
                ElseIf SourceType = "SQL" Then
                    bulkCopy.DestinationTableName = "ATT_PREIMPORT"
                    Me.UpdateProcessedRecords(QueryString)
                End If
                bulkCopy.BulkCopyTimeout = 60
                bulkCopy.WriteToServer(DataTable)
                conHana.Close()
            Else
                Me.AddToFileIN("No new records found from biometric machine")
            End If

        Catch ex As Exception
            Me.AddToFileIN("HANA Connection Error:" + ex.Message + "--" + System.DateTime.Now())
        End Try
    End Sub

    'Public Function GetSqlConnection(ByVal query As String) As DataTable
    '    Try
    '        Dim dtTable As DataTable = Nothing
    '        Dim connetionString As String
    '        Dim cnn As SqlConnection
    '        connetionString = ConfigurationSettings.AppSettings.Get("SQLConnectionString").ToString()
    '        ''connetionString = "Data Source=TNTDBSRV\TIPSANDTOES_STD;Initial Catalog=TAACS_TIPS_AND_TOS;User ID=tntsap;Password=Tnt1@1320"
    '        cnn = New SqlConnection(connetionString)
    '        'cnn.Open()

    '        Dim cmd As SqlCommand = New SqlCommand(query, cnn)
    '        Dim da As SqlDataAdapter = New SqlDataAdapter(cmd)
    '        Dim ds As DataSet = New DataSet()
    '        da.Fill(ds)


    '        If ds IsNot Nothing Then
    '            dtTable = ds.Tables(0)
    '        End If
    '        'cnn.Close()
    '        Me.AddToFileIN("---------------Data fetched from the SQL table--------------------" + System.DateTime.Now())
    '        Return dtTable
    '    Catch ex As Exception
    '        Me.AddToFileIN("SQL Connection Error:" + ex.Message + "--" + System.DateTime.Now())
    '    End Try
    'End Function

    Public Function UpdateProcessedRecords(ByVal query As String) As String
        Try
            Dim connetionString As String
            Dim cnn As SqlConnection
            connetionString = ConfigurationSettings.AppSettings.Get("SQLConnectionString").ToString()
            'connetionString = "Data Source=TNTDBSRV\TIPSANDTOES_STD;Initial Catalog=TAACS_TIPS_AND_TOS;User ID=tntsap;Password=Tnt1@1320"
            cnn = New SqlConnection(connetionString)
            cnn.Open()
            Dim cmd As SqlCommand = New SqlCommand(query, cnn)
            cmd.ExecuteNonQuery()
            cnn.Close()
            Me.AddToFileIN("---------------Data Updated in the SQL table--------------------" + System.DateTime.Now())
            Return "Success"
        Catch ex As Exception
            Me.AddToFileIN("SQL Connection Error:" + ex.Message + "--" + System.DateTime.Now())
        End Try
    End Function

    Public Function UpdateProcessedRecords_MsAccess(ByVal query As String) As String
        Try
            Dim dt As New DataTable
            Dim da As New OleDb.OleDbDataAdapter
            'Dim App_Connection As String = ConfigurationSettings.AppSettings.Get("MSACCESSConnectionString").ToString()
            'Dim con As New OleDb.OleDbConnection()
            'Dim con As New OleDb.OleDbConnection("Provider = Microsoft.Jet.OLEDB.4.0;Data Source=""D:\ATT BACKUP\ATT2000.MDB"" ")
            Dim con As New OleDb.OleDbConnection("Provider = Microsoft.Jet.OLEDB.4.0;Data Source=""D:\paylite\Paylite Backup file\DATA FILE 23-02-2021\ATT2000.MDB"" ")
            Try
                con.Open()
                If con.State = ConnectionState.Open Then
                    AddToFileIN("Connected")
                    Dim cmd As OleDb.OleDbCommand = New OleDb.OleDbCommand(query, con)
                    cmd.Connection = con
                    cmd.ExecuteNonQuery()
                Else
                    AddToFileIN("Not Connected!")
                End If
            Catch ex As Exception
                AddToFileIN(ex.Message)
            Finally
                con.Close()
            End Try
            con.Close()
        Catch ex As Exception
            AddToFileIN(ex.Message)
        Finally

        End Try

        'Try
        '    Dim connetionString As String
        '    Dim cnn As SqlConnection
        '    connetionString = ConfigurationSettings.AppSettings.Get("SQLConnectionString").ToString()
        '    cnn = New SqlConnection(connetionString)
        '    cnn.Open()
        '    Dim cmd As SqlCommand = New SqlCommand(query, cnn)
        '    cmd.ExecuteNonQuery()
        '    cnn.Close()
        '    Me.AddToFileIN("---------------Data Updated in the SQL table--------------------" + System.DateTime.Now())
        '    Return "Success"
        'Catch ex As Exception
        '    Me.AddToFileIN("SQL Connection Error:" + ex.Message + "--" + System.DateTime.Now())
        'End Try
    End Function

    Public Function UpdateAPIDataInHANA(ByVal USERCODE As String, ByVal StartDate As String, ByVal EndDate As String, ByVal ConnectionString As String)
        Try
            Dim Query As String = ""
            Dim UserName As String = ConfigurationSettings.AppSettings("BiometricUSERID").ToString()
            Dim Password As String = ConfigurationSettings.AppSettings("BiometricPassword").ToString()
            Dim BiometricAPI As String = ConfigurationSettings.AppSettings("BiometricAPI").ToString()
            Dim Cred As String = UserName + ":" + Password

            Dim cmd As HanaCommand = New HanaCommand
            'Dim App_Connection As String = ConfigurationSettings.AppSettings.Get("HANAConnectionString").ToString()
            'Dim SourceType As String = ConfigurationSettings.AppSettings.Get("SourceType").ToString()

            Dim conHana As HanaConnection = New HanaConnection(ConnectionString)
            conHana.Open()
            Dim URLStr As String = BiometricAPI & "/api.svc/v2/attendance-daily?action=get;date-range=" & StartDate & "-" & EndDate & ";range=user;Id=" & USERCODE
            'Dim req As WebRequest = WebRequest.Create("http://192.168.3.37/cosec/api.svc/v2")
            'Dim req As WebRequest = WebRequest.Create("http://192.168.3.37/cosec/api.svc/v2/attendance-daily?action=get;date-range=01092021-30092021;range=user;Id=A017")
            Dim req As WebRequest = WebRequest.Create(URLStr)
            req.Method = "GET"
            req.Headers("Authorization") = "Basic " & Convert.ToBase64String(Encoding.Default.GetBytes(Cred))
            'req.Credentials = new NetworkCredential("username", "password");
            Dim resp As HttpWebResponse = TryCast(req.GetResponse(), HttpWebResponse)
            Dim response As String = ""
            Using (resp)
                Dim httpResponse As HttpWebResponse = CType(resp, HttpWebResponse)
                Dim statusCode As Integer = httpResponse.StatusCode
                Try
                    Using responseStream = req.GetResponse.GetResponseStream
                        Using reader As New StreamReader(responseStream)
                            response = reader.ReadToEnd()

                        End Using
                    End Using
                Catch ex As Exception
                End Try
            End Using

            Dim s As String = response
            Dim DataRow As IList(Of String) = New List(Of String)(s.Split(New String() {vbNewLine}, StringSplitOptions.None))
            Dim i As Integer = 1

            For Each element As String In DataRow
                If i > 1 Then
                    Dim LineData As String = element
                    Dim RowData As IList(Of String) = New List(Of String)(LineData.Split(New String() {"|"}, StringSplitOptions.None))
                    Dim USERID As String = RowData(0)
                    If USERID <> "<EOT>" Then

                        Dim NAME As String = RowData(1)
                        Dim PunchDateStr As String = RowData(2).Substring(0, 10)
                        'Dim PunchDate As Date = CDate(PunchDateStr.Substring(0, 10))
                        'Dim oDate As Date = Date.TryParseExact(PunchDateStr, "dd/MM/yyyy", System.Globalization.CultureInfo.InvariantCulture)
                        Dim oDate As DateTime = DateTime.ParseExact(PunchDateStr, "dd/MM/yyyy", System.Globalization.CultureInfo.InvariantCulture)
                        Dim PunchDate As String = oDate.ToString("yyyyMMdd")
                        Dim INPunch As String = RowData(3)
                        Dim OUTPunch As String = RowData(4)
                        'If INPunch.Length() > 0 Then
                        '    INPunch = INPunch.Substring(11, 5)
                        'End If
                        'If OUTPunch.Length() > 0 Then
                        '    OUTPunch = OUTPunch.Substring(11, 5)
                        'End If
                        Query = "SELECT ""USERID"" FROM  ""ATT_PREIMPORTSH"" WHERE ""USERID""='" & USERID & "' AND  ""DATE""='" & PunchDate & "' "
                        'cmd = New HanaCommand(Query, conHana)
                        'cmd.ExecuteNonQuery()
                        cmd = New HanaCommand(Query, conHana)
                        Dim da As HanaDataAdapter = New HanaDataAdapter(cmd)
                        Dim ds As DataSet = New DataSet()
                        da.Fill(ds)
                        Dim Row As Integer
                        If ds IsNot Nothing Then
                            Row = ds.Tables(0).Rows.Count
                        End If
                        Dim Test As String = ""
                        If Row > 0 Then
                            Query = "Update ""ATT_PREIMPORTSH"" set ""DATE"" = '" & PunchDate & "',""IN"" = '" & INPunch & "',""OUT"" = '" & OUTPunch & "' Where ""USERID""= '" & USERID & "'  AND  ""DATE""='" & PunchDate & "' "
                        Else
                            Query = "insert into ""ATT_PREIMPORTSH"" (""USERID"",""FIRSTNAME"",""DATE"",""IN"",""OUT"") values('" & USERID & "','" & NAME & "','" & PunchDate & "','" & INPunch & "','" & OUTPunch & "')"
                        End If
                        Dim cmd1 As HanaCommand = New HanaCommand
                        cmd1 = New HanaCommand(Query, conHana)
                        cmd1.ExecuteNonQuery()

                    End If
                End If
                i = i + 1
            Next

            conHana.Close()
        Catch ex As Exception
            AddToFileIN(ex.Message)
        End Try
    End Function

    Private Sub AddToFileIN(ByVal contents As String)
        Try
            Using TextWriter As StreamWriter = New StreamWriter(System.Configuration.ConfigurationSettings.AppSettings("LogFile") & "LogFile_IN" & Today.ToString("dd-MM-yyyy") & ".txt", True)
                TextWriter.WriteLine(contents)
            End Using
        Catch ex As Exception
            'Me.AddToFileIN("AddToFile:" + ex.Message + System.DateTime.Now())
        End Try
    End Sub

    Function GetData() As DataTable
        Try
            Dim sql As String
            Dim cmd As New OleDb.OleDbCommand
            Dim dt As New DataTable
            ''dt = Nothing
            Dim da As New OleDb.OleDbDataAdapter
            Dim App_Connection As String = ConfigurationSettings.AppSettings.Get("MSACCESSConnectionString").ToString()
            Dim con As New OleDb.OleDbConnection(App_Connection)
            'Dim con As New OleDb.OleDbConnection("Provider = Microsoft.Jet.OLEDB.4.0;Data Source=""D:\ATT BACKUP\ATT2000.MDB"" ")
            'Dim con As New OleDb.OleDbConnection("Provider = Microsoft.Jet.OLEDB.4.0;Data Source=""D:\paylite\Paylite Backup file\DATA FILE 23-02-2021\ATT2000.MDB"" ")

            Try
                con.Open()
                If con.State = ConnectionState.Open Then
                    AddToFileIN("Connected")
                    'sql = "Select * from CHECKINOUT Where IsProcessed = '0' or IsProcessed is null "
                    'sql = "Select * from CHECKINOUT Where CHECKTIME between #01/05/2021# and #31/07/2021# "
                    'sql = "Select B.SSN as USERID, A.CHECKTIME, A.CHECKTYPE, A.VERIFYCODE, A.SENSORID, A.MemoInfo, A.WorkCode, A.sn, A.UserExtFmt " +
                    '" from CHECKINOUT A LEFT JOIN USERINFO B ON A.USERID = B.USERID Where A.CHECKTIME between #30/06/2021# and #31/07/2021# "
                    '
                    sql = "Select B.SSN as USERID, A.CHECKTIME, A.CHECKTYPE, A.VERIFYCODE, A.SENSORID, A.MemoInfo, A.WorkCode, A.sn, A.UserExtFmt " +
                    " from CHECKINOUT A LEFT JOIN USERINFO B ON A.USERID = B.USERID Where A.IsProcessed = 0 or A.IsProcessed is null "

                    cmd.Connection = con
                    cmd.CommandText = sql
                    da.SelectCommand = cmd
                    da.Fill(dt)
                Else
                    AddToFileIN("Not Connected!")
                End If
            Catch ex As Exception
                AddToFileIN(ex.Message)
            Finally
                con.Close()
            End Try
            con.Close()
            Return dt
        Catch ex As Exception
            AddToFileIN(ex.Message)
        Finally
        End Try
    End Function

    Dim cntRecord As Integer

    Sub SQLIntegration()
        Dim cmd As HanaCommand = New HanaCommand
        Dim conHana As New HanaConnection
        Dim SQLDt As DataTable

        Try
            Dim DatabaseList As String = ConfigurationSettings.AppSettings.Get("DatabaseList").ToString()
            Dim ConnectionStringList As String()
            Dim HANADatabase As String = ""
            If DatabaseList <> "" Then

                ConnectionStringList = DatabaseList.Split(",")
                For k As Integer = 0 To ConnectionStringList.Length - 1 '------For each database
                    HANADatabase = ConnectionStringList(k)
                    cntRecord = 0
                    AddToFileIN("Connected DB - " + HANADatabase + " - " + System.DateTime.Now())
                    '--------Each database
                    HANAConnection = ConfigurationSettings.AppSettings(HANADatabase).ToString()
                    Dim employeeListQry As String = "SELECT ""ExtEmpNo"", IFNULL((SELECT ""U_StartDate"" FROM ""@SBO_BIOMETRIC""),(SELECT ""U_AS"" FROM ""@SBO_PRCONTROL"")) AS ""StartDate"", " &
                    " (SELECT ""U_NPDate"" FROM ""@SBO_PRCONTROL"") AS ""EndDate"",(SELECT TOP 1 ""Code"" FROM ""@SBO_SHIFTMST"") As ""SHIFT"" FROM OHEM Where ""Active""='Y' order by ""ExtEmpNo"" "
                    'Dim employeeListQry As String = "SELECT ""ExtEmpNo"",(SELECT ""U_AS"" FROM ""@SBO_PRCONTROL"") AS ""StartDate"",(SELECT ""U_NPDate"" FROM ""@SBO_PRCONTROL"") AS ""EndDate"" " & _
                    '    " ,(SELECT TOP 1 ""Code"" FROM ""@SBO_SHIFTMST"") As ""SHIFT"" FROM OHEM Where ""Active""='Y'"
                    dsEmployeeList = Me.getDataSet(employeeListQry)
                    Dim DT As DataTable = Nothing
                    Dim RowsCount As Integer
                    Dim Shift As String = ""
                    Dim StartDate As Date
                    Dim EndDate As Date
                    If dsEmployeeList IsNot Nothing Then
                        RowsCount = dsEmployeeList.Tables(0).Rows.Count
                        DT = dsEmployeeList.Tables(0)
                        StartDate = "2025-06-07" 'dsEmployeeList.Tables(0).Rows(0)("StartDate")
                        EndDate = "2025-06-10" 'DateTime.Now().ToString("yyyy/MM/dd")
                        Shift = dsEmployeeList.Tables(0).Rows(0)("SHIFT")
                    End If
                    '------------SQL data in data table

                    Dim Str As String = " Select emp_code 'USERID','' 'NAME',Convert(Date, punch_time) 'DATE'" &
                                " ,min(convert(time(0),punch_time))  'IN',max(convert(time(0),punch_time)) 'OUT' " &
                                " ,'' 'OverTime','' 'Short','' 'Remarks','' 'DayStatus','' 'DayStatus1','' 'DayStatus2' " &
                                " ,'' 'Sync','' 'FileName'  FROM [iclock_transaction]" &
                                " Where CONVERT(DATE, punch_time) Between '" & StartDate & "' and '" & EndDate & "'" &
                                " GROUP BY CONVERT(DATE, punch_time) ,emp_code Order by emp_code,Convert(Date, punch_time) "

                    'Dim Str As String = " Select emp_code 'USERID','' 'NAME',Convert(Date, punch_time) 'DATE'" &
                    '            " ,min(convert(time(0),punch_time))  'IN',max(convert(time(0),punch_time)) 'OUT' " &
                    '            " ,'' 'OverTime','' 'Short','' 'Remarks','' 'DayStatus','' 'DayStatus1','' 'DayStatus2' " &
                    '            " ,'' 'Sync','' 'FileName'  FROM [iclock_transaction]" &
                    '            " Where emp_code = '600391' and CONVERT(DATE, punch_time) Between '" & StartDate & "' and '" & EndDate & "'" &
                    '            " GROUP BY CONVERT(DATE, punch_time) ,emp_code Order by emp_code,Convert(Date, punch_time) "

                    dsSQLEmployeeData = Me.getSQLDataSet(Str)
                    SQLDt = dsSQLEmployeeData.Tables(0)
                    If RowsCount > 0 And SQLDt.Rows.Count > 0 Then
                        For Each row As DataRow In DT.Rows
                            Dim ExtEmpNo As String = row(0).ToString()
                            'Dim StartDate1 As Date = row(1).ToString()
                            'Dim EndDate1 As Date = row(2).ToString()
                            'Dim Shift As String = row(3).ToString()
                            'Dim StartDate As Date = StartDate1
                            'Dim EndDate As Date = DateTime.Now().ToString("yyyy/MM/dd")

                            Me.AddUpdateSQLDataInHANA(ExtEmpNo, StartDate, EndDate, HANAConnection, Shift, SQLDt)
                        Next
                    End If
                    Dim UpdateDateQry As String = "Update ""@SBO_BIOMETRIC"" set ""U_StartDate"" = '" & DateTime.Now.ToString("yyyyMMdd") & "'"
                    'Dim UpdateDateQry As String = "Update ""@SBO_BIOMETRIC"" set ""U_StartDate"" = '" & DateTime.Today.AddDays(-1).ToString("yyyy/MM/dd") & "' "
                    Me.ExecuteNonQuery(UpdateDateQry)
                    Me.AddToFileIN("Processed Records : " & cntRecord & "---" + System.DateTime.Now())
                Next

            End If
        Catch ex As Exception
            AddToFileIN("Exception ---------------------------------" & ex.Message)
        Finally
            If conHana.State = ConnectionState.Open Then
                conHana.Close()
            End If
        End Try
    End Sub

    Public Function AddUpdateSQLDataInHANA(ByVal USERCODE As String, ByVal StartDate As Date, ByVal EndDate As Date, ByVal ConnectionString As String, ByVal Shift As String, ByRef SQLDt As DataTable)
        Try
            'Me.AddToFileIN("------------------------------------------------------------------" + System.DateTime.Now())
            'Me.AddToFileIN("Processing : " & USERCODE & "----------------------" + System.DateTime.Now())
            Dim WhereCon As String = "(USERID = '" & USERCODE & "' or USERID = '0" & USERCODE & "') and DATE >= #" & StartDate & "# AND DATE <= #" & EndDate & "#"
            Dim bioData = SQLDt.Select(WhereCon)

            'If bioData.Length > 0 Then
            '    Me.AddToFileIN("Processing : " & USERCODE & "----------------------" + System.DateTime.Now())
            'End If

            For Each bioDataRow As DataRow In bioData
                Dim USERID As String = bioDataRow("USERID")
                Dim NAME As String = ""
                Dim PunchDate As Date = bioDataRow("DATE")
                Dim PunchDateStr As String = PunchDate.ToString("yyyyMMdd")
                Dim INPunch As String = bioDataRow("IN").ToString()
                Dim OUTPunch As String = bioDataRow("OUT").ToString()
                Dim empExistQry As String = "SELECT ""USERID"" FROM  ""ATT_PREIMPORTSH"" WHERE ""USERID""='" & USERID & "' AND  ""DATE""='" & PunchDateStr & "' "
                dsExistData = Me.getDataSet(empExistQry)
                Dim Row As Integer
                If dsExistData IsNot Nothing Then
                    Row = dsExistData.Tables(0).Rows.Count
                End If
                Try
                    Dim AddUpdateQry As String
                    If Row > 0 Then
                        AddUpdateQry = "Update ""ATT_PREIMPORTSH"" set ""IN"" = '" & INPunch & "',""OUT"" = '" & OUTPunch & "',""SHIFT""='" & Shift & "' Where ""USERID""= '" & USERID & "' and ""DATE"" = '" & PunchDateStr & "' "
                        Me.ExecuteNonQuery(AddUpdateQry)
                    Else
                        AddUpdateQry = "insert into ""ATT_PREIMPORTSH"" (""USERID"",""FIRSTNAME"",""DATE"",""IN"",""OUT"",""SHIFT"") values('" & USERID & "','" & NAME & "','" & PunchDateStr & "','" & INPunch & "','" & OUTPunch & "','" & Shift & "')"
                        Me.ExecuteNonQuery(AddUpdateQry)
                        cntRecord = cntRecord + 1
                    End If

                Catch ex As Exception
                    AddToFileIN(ex.Message)
                End Try
            Next
            'Dim DataTable As DataTable = SQLDt
            'If DataTable.Rows.Count > 0 Then
            '    For i As Integer = 0 To DataTable.Rows.Count - 1
            '        Dim USERID As String = DataTable.Rows(i).Item(0)
            '        Dim NAME As String = ""
            '        Dim PunchDateStr As Date = DataTable.Rows(i).Item(2)

            '        Dim PunchDate As String = PunchDateStr.ToString("yyyyMMdd")
            '        Dim INPunch As String = DataTable.Rows(i).Item(3).ToString()
            '        Dim OUTPunch As String = DataTable.Rows(i).Item(4).ToString()

            '        Dim empExistQry As String = "SELECT ""USERID"" FROM  ""ATT_PREIMPORTSH"" WHERE ""USERID""='" & USERID & "' AND  ""DATE""='" & PunchDate & "' "
            '        dsExistData = Me.getDataSet(empExistQry)
            '        Dim Row As Integer
            '        If dsExistData IsNot Nothing Then
            '            Row = dsExistData.Tables(0).Rows.Count
            '        End If

            '        Try
            '            Dim AddUpdateQry As String
            '            If Row > 0 Then
            '                AddUpdateQry = "Update ""ATT_PREIMPORTSH"" set ""DATE"" = '" & PunchDate & "',""IN"" = '" & INPunch & "',""OUT"" = '" & OUTPunch & "',""SHIFT""='" & Shift & "' Where ""USERID""= '" & USERID & "'  AND  ""DATE""='" & PunchDate & "' "
            '            Else
            '                AddUpdateQry = "insert into ""ATT_PREIMPORTSH"" (""USERID"",""FIRSTNAME"",""DATE"",""IN"",""OUT"",""SHIFT"") values('" & USERID & "','" & NAME & "','" & PunchDate & "','" & INPunch & "','" & OUTPunch & "','" & Shift & "')"
            '            End If
            '            Me.ExecuteNonQuery(AddUpdateQry)
            '        Catch ex As Exception
            '            AddToFileIN(ex.Message)
            '        End Try
            '    Next
            'End If

        Catch ex As Exception
            AddToFileIN(ex.Message)
        End Try
    End Function


    Public Function getSQLDataSet(strSql As String) As DataSet
        Dim cnn As SqlConnection
        Dim SQLconnetionString As String = ConfigurationSettings.AppSettings.Get("SQLConnectionString").ToString()
        cnn = New SqlConnection(SQLconnetionString)
        Dim cmd As SqlCommand = New SqlCommand(strSql, cnn)
        AddToFileIN("SQL Querry " & strSql & "--------" + System.DateTime.Now())
        Dim da As SqlDataAdapter = New SqlDataAdapter(cmd)
        Dim ds As DataSet = New DataSet()
        Try
            da.Fill(ds)
        Catch ex As Exception
            AddToFileIN(ex.Message)
            Throw ex
        End Try
        Return ds
    End Function

    Public Function getDataSet(strSql As String) As DataSet
        con = New HanaConnection(HANAConnection)
        Dim cmd As New HanaCommand(strSql, con)
        AddToFileIN("SQL Querry " & strSql & "--------" + System.DateTime.Now())
        Dim da As New HanaDataAdapter(cmd)
        Dim ds As New DataSet
        Try
            da.Fill(ds)
        Catch ex As Exception
            AddToFileIN("Data Set problem" & ex.Message)
            Throw ex
        End Try
        Return ds

    End Function

    Public Function ExecuteScalar(strSql As String) As Object
        con = New HanaConnection(HANAConnection)
        Dim cmd As New HanaCommand(strSql, con)
        Try
            con.Open()
            Return cmd.ExecuteScalar()
            con.Close()
        Catch ex As Exception
            AddToFileIN(ex.Message)
            Throw ex
        Finally
            con.Close()
        End Try
    End Function

    Public Sub ExecuteNonQuery(strSql As String)
        con = New HanaConnection(HANAConnection)
        Dim cmd As New HanaCommand(strSql, con)
        Try
            con.Open()
            cmd.ExecuteNonQuery()
            con.Close()
        Catch ex As Exception
            AddToFileIN(ex.Message)
            Throw ex
        Finally
            con.Close()
        End Try
    End Sub


End Class

