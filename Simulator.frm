VERSION 5.00
Begin VB.Form Simulator 
   BackColor       =   &H00FFFFFF&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Simulator"
   ClientHeight    =   2436
   ClientLeft      =   36
   ClientTop       =   384
   ClientWidth     =   3984
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   203
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   332
   StartUpPosition =   3  '����ȱʡ
   Begin VB.Timer Mover 
      Enabled         =   0   'False
      Interval        =   1
      Left            =   1800
      Top             =   0
   End
   Begin VB.Label fps 
      BackStyle       =   0  'Transparent
      Caption         =   $"Simulator.frx":0000
      BeginProperty Font 
         Name            =   "DejaVu Sans Mono"
         Size            =   10.2
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   732
      Left            =   120
      TabIndex        =   0
      Top             =   360
      Width           =   3732
   End
   Begin VB.Shape Person 
      BorderColor     =   &H0041D900&
      BorderWidth     =   2
      FillColor       =   &H00FFAB1A&
      FillStyle       =   0  'Solid
      Height          =   372
      Index           =   0
      Left            =   3600
      Shape           =   3  'Circle
      Top             =   0
      Visible         =   0   'False
      Width           =   372
   End
   Begin VB.Line RightEnd 
      BorderColor     =   &H00000000&
      BorderWidth     =   8
      X1              =   90
      X2              =   140
      Y1              =   20
      Y2              =   70
   End
   Begin VB.Line LeftEnd 
      BorderColor     =   &H00000000&
      BorderWidth     =   8
      X1              =   60
      X2              =   10
      Y1              =   20
      Y2              =   70
   End
   Begin VB.Shape RightWall 
      BorderStyle     =   0  'Transparent
      FillColor       =   &H00135F80&
      FillStyle       =   0  'Solid
      Height          =   252
      Left            =   1320
      Top             =   0
      Width           =   372
   End
   Begin VB.Shape LeftWall 
      BorderStyle     =   0  'Transparent
      FillColor       =   &H00135F80&
      FillStyle       =   0  'Solid
      Height          =   252
      Left            =   120
      Top             =   0
      Width           =   372
   End
End
Attribute VB_Name = "Simulator"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private HumanRadius As Integer
Private PsgwayWidth As Integer
Private MaxAngle As Integer
Private SectorRadius As Integer
Private PersonCount As Integer
Private WalkSpeed As Double
Private ShakeSpeed As Double
Private ViewCenter As POINT
Private FieldWidth As Double
Private Fieldheight As Double
Private realPoint() As POINT

Private lastTime As Long
Private startTime As Long

Private Al As Double, Bl As Double, Cl As Double
Private Ar As Double, Br As Double, Cr As Double

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
'    realPoint(0).X = X - SectorRadius * Sin(AngleToRadian(MaxAngle) / 2) - PsgwayWidth / 2
'    realPoint(0).Y = Y - HumanRadius * 3
End Sub

'��ʼ��
Public Sub Start(HumanRadius_ As Integer, PsgwayWidth_ As Integer, MaxAngle_ As Integer, SectorRadius_ As Integer, PersonCount_ As Integer, WalkSpeed_ As Double, ShakeSpeed_ As Double)
    HumanRadius = HumanRadius_
    PsgwayWidth = PsgwayWidth_
    MaxAngle = MaxAngle_
    SectorRadius = SectorRadius_
    PersonCount = PersonCount_
    WalkSpeed = WalkSpeed_
    ShakeSpeed = ShakeSpeed_
    
    ReDim realPoint(0 To PersonCount) As POINT
    FieldWidth = SectorRadius * Sin(AngleToRadian(MaxAngle) / 2) * 2 + PsgwayWidth
    Fieldheight = SectorRadius
    ViewCenter.X = FieldWidth / 2
    ViewCenter.Y = LeftWall.Height
    Randomize
    Person(0).Width = HumanRadius * 2
    Person(0).Height = HumanRadius * 2
    Person(0).Left = -Person(0).Width * 2
    Dim tempPoint As POINT
    For n = 1 To PersonCount
        Do
            tempPoint.X = (Rnd() - 0.5) * FieldWidth
            tempPoint.Y = Rnd() * Fieldheight
        Loop While isOutOfRange(tempPoint, SectorRadius, MaxAngle, PsgwayWidth)
        realPoint(n) = tempPoint
        Load Person(n)
        Person(n).Visible = True
    Next
    refreshDisplay
    
    kl = -Atn(AngleToRadian(90 - MaxAngle / 2))
    Al = kl
    Bl = -1
    Cl = -kl * (-PsgwayWidth / 2) + 0    ' C = -ka + b ������ѡ�� y ��Ϊ 0 �ĵ�
    kr = Atn(AngleToRadian(90 - MaxAngle / 2))
    Ar = kr
    Br = -1
    Cr = -kr * (PsgwayWidth / 2) + 0    ' C = -ka + b ������ѡ�� y ��Ϊ 0 �ĵ�
    
    Mover.Enabled = True
    lastTime = GetTickCount     '�� fps ��
    startTime = lastTime
End Sub

'��ʼ����Աλ��ʱ�ж���û�г���
Private Function isOutOfRange(point_ As POINT, ByVal SectorRadius_ As Double, ByVal MaxAngle_ As Double, ByVal extraWidth As Double) As Boolean
    isOutOfRange = True
    If Abs(point_.X) < extraWidth / 2 Then                                                                  '���м�������
        If point_.Y < SectorRadius_ Then
            isOutOfRange = False
        End If
    ElseIf point_.Y / (Abs(point_.X) - Abs(wxtrawidth)) >= Abs(Tan(AngleToRadian(90 - MaxAngle_ / 2))) Then '������������
        If point_.X ^ 2 + point_.Y ^ 2 <= SectorRadius ^ 2 Then
            isOutOfRange = False
        End If
    End If
End Function

'�������е���ͬ��������
Private Sub refreshDisplay()
    For i = 1 To UBound(realPoint)
        Person(i).Move realPoint(i).X - HumanRadius + ViewCenter.X, realPoint(i).Y - HumanRadius + ViewCenter.Y
        'DoEvents
        'Sleep 300
    Next
End Sub

'��ª����ײ��⣬����Ӧ�ûص��ľ���
Private Function calcForce(ByVal index As Integer) As POINT
    Dim d As Double                        '��ʱ�������������
    Dim direction As Double, depth As Double
    For i = 1 To UBound(realPoint)          '���������ˣ�����û������
        If index <> i Then
            d = Sqr((realPoint(i).X - realPoint(index).X) ^ 2 + (realPoint(i).Y - realPoint(index).Y) ^ 2)
            depth = HumanRadius * 2 - d     'Ƕ��ȥ�����
            If depth > 0 Then               '������ײ
                direction = Atn((realPoint(i).Y - realPoint(index).Y) / (realPoint(i).X - realPoint(index).X))
                If (realPoint(i).X - realPoint(index).X) < 0 Then direction = direction + PI   'arctan Ҫ������ʹ��
                calcForce.X = calcForce.X - Cos(direction) * WalkSpeed * depth * 0.1
                calcForce.Y = calcForce.Y - Sin(direction) * WalkSpeed * depth * 0.1
            End If
        End If
    Next
    'Debug.Print ""
    '������߽磬һԪһ�η��̵�бʽתһ��ʽ�㷨
    Dim dl As Double
    dl = Abs(Al * realPoint(index).X + Bl * realPoint(index).Y + Cl) / Sqr(Al ^ 2 + Bl ^ 2)       '�㵽ֱ�߾���
    depth = HumanRadius - dl
    If depth > 0 Then
        If realPoint(index).Y - dl * Sin(AngleToRadian(MaxAngle / 2)) > 0 Then
            'direction = Atn(1 / -kl)         '��������Ǵ��ߵĽǶȣ�����ȡ���෴��������֪Ϊ��������������
            direction = AngleToRadian(MaxAngle / 2)
            'Debug.Print ("left_d: " & Round(d, 1) & "  leftAngle: " & RadianToAngle(direction))
            calcForce.X = calcForce.X + Cos(direction) * WalkSpeed * depth * 1
            calcForce.Y = calcForce.Y + Sin(direction) * WalkSpeed * depth * 1
        End If
    End If
    '�����ұ߽磬һԪһ�η��̵�бʽתһ��ʽ�㷨
    Dim dr As Double
    dr = Abs(Ar * realPoint(index).X + Br * realPoint(index).Y + Cr) / Sqr(Ar ^ 2 + Br ^ 2)       '�㵽ֱ�߾���
    depth = HumanRadius - dr
    If depth > 0 Then
        If realPoint(index).Y - dr * Sin(AngleToRadian(MaxAngle / 2)) > 0 Then
            'direction = Atn(1 / -kr) + PI    '��������Ǵ��ߵĽǶȣ�����ȡ�˵��෴�������� tan ����������� PI����֪Ϊ��������������
            direction = PI - AngleToRadian(MaxAngle / 2)
            'Debug.Print ("right_d: " & Round(d, 1) & "  rightAngle: " & RadianToAngle(direction))
            calcForce.X = calcForce.X + Cos(direction) * WalkSpeed * depth * 1
            calcForce.Y = calcForce.Y + Sin(direction) * WalkSpeed * depth * 1
        End If
    End If
End Function

Private Function walkForward(ByVal index As Integer) As POINT
    Dim direction As Double
    If realPoint(index).Y < 0 Then                                      '��ȥ��
        walkForward.Y = -WalkSpeed
    ElseIf realPoint(index).X - HumanRadius < -PsgwayWidth / 2 Then     '���
        direction = Atn(realPoint(index).Y / (realPoint(index).X + PsgwayWidth / 2 - HumanRadius))
        walkForward.X = Cos(direction) * WalkSpeed
        walkForward.Y = Sin(direction) * WalkSpeed
    ElseIf realPoint(index).X + HumanRadius > PsgwayWidth / 2 Then      '�ұ�
        direction = Atn(realPoint(index).Y / (realPoint(index).X - PsgwayWidth / 2 + HumanRadius))
        direction = direction + PI  'arctan Ҫ������ʹ��
        walkForward.X = Cos(direction) * WalkSpeed
        walkForward.Y = Sin(direction) * WalkSpeed
    Else                                                                '�м�
        walkForward.Y = -WalkSpeed
    End If
End Function

Private Function walkRandom(ByVal index As Integer) As POINT
    Dim direction As Double
    Randomize
    direction = Rnd * PI * 2
    walkRandom.X = Cos(direction) * ShakeSpeed
    walkRandom.Y = Sin(direction) * ShakeSpeed
End Function

Private Sub Mover_Timer()
    Dim deltaTime As Long               '����ƽ�� fps �������ٶȲ���
    deltaTime = GetTickCount - lastTime
    If deltaTime < 16 Then Exit Sub     '��������֡��
    Dim speedMultiply As Single
    speedMultiply = deltaTime / 16.6667 '�� 60 fps Ϊ��׼
    Static deltaTimeSum As Long
    If deltaTimeSum >= 333 Then
        fps = "fps: " & Round(1000 / deltaTime, 1) & vbNewLine & "speedMultiply: " & Round(speedMultiply, 1) & "��" & vbNewLine & "time: " & GetTickCount - startTime & " ms"
        If speedMultiply >= 4 Then fps.ForeColor = vbRed Else fps.ForeColor = vbBlack
        deltaTimeSum = 0
    Else
        deltaTimeSum = deltaTimeSum + deltaTime
    End If
    lastTime = GetTickCount
    
    Dim finished As Boolean
    finished = True
    For i = 1 To UBound(realPoint)
        If realPoint(i).Y > 0 Then finished = False: Exit For
    Next
    If finished = True Then
        fps = "Totaltime: " & GetTickCount - startTime
        Mover.Enabled = False
    End If
    ReDim nextPoint(UBound(realPoint)) As POINT
    For i = 1 To UBound(realPoint)
        Dim movement As POINT
        movement = calcForce(i)
        nextPoint(i).X = realPoint(i).X + movement.X * speedMultiply  '�� 60 fps Ϊ��׼
        nextPoint(i).Y = realPoint(i).Y + movement.Y * speedMultiply
        movement = walkForward(i)
        nextPoint(i).X = nextPoint(i).X + movement.X * speedMultiply  '�� 60 fps Ϊ��׼
        nextPoint(i).Y = nextPoint(i).Y + movement.Y * speedMultiply  '�� 60 fps Ϊ��׼
        movement = walkRandom(i)
        nextPoint(i).X = nextPoint(i).X + movement.X * speedMultiply  '�� 60 fps Ϊ��׼
        nextPoint(i).Y = nextPoint(i).Y + movement.Y * speedMultiply  '�� 60 fps Ϊ��׼
    Next
    For i = 1 To UBound(realPoint)
        realPoint(i) = nextPoint(i)
    Next
    refreshDisplay
    'Debug.Print "========================="
End Sub


