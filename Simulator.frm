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
      Caption         =   "fps:"
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
      Height          =   252
      Left            =   120
      TabIndex        =   0
      Top             =   240
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

Private Sub Form_Unload(Cancel As Integer)
    End
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
    
    ReDim realPoint(1 To PersonCount) As POINT
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
    Mover.Enabled = True
    lastTime = GetTickCount     '�� fps ��
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
    Dim d As Double                         '��ʱ�������������͵㵽ֱ�߾���
    Dim direction As Double, depth As Double
    For i = 1 To UBound(realPoint)          '���������ˣ�����û������
        If index <> i Then
            d = Sqr((realPoint(i).X - realPoint(index).X) ^ 2 + (realPoint(i).Y - realPoint(index).Y) ^ 2)
            depth = HumanRadius * 2 - d     'Ƕ��ȥ�����
            If depth > 0 Then               '������ײ
                direction = Atn((realPoint(i).Y - realPoint(index).Y) / (realPoint(i).X - realPoint(index).X))
                If (realPoint(i).X - realPoint(index).X) < 0 Then direction = direction + 180   'arctan Ҫ������ʹ��
                calcForce.X = calcForce.X - Cos(direction) * WalkSpeed * depth / HumanRadius * 2
                calcForce.Y = calcForce.Y - Sin(direction) * WalkSpeed * depth / HumanRadius * 2
            End If
        End If
    Next
    'Debug.Print ""
    Dim A As Double, B As Double, C As Double, k As Double
    '������߽磬һԪһ�η��̵�бʽתһ��ʽ�㷨
    k = -Atn(AngleToRadian(90 - MaxAngle / 2))
    A = k
    B = -1
    C = -k * (-PsgwayWidth / 2) + 0    ' C = -ka + b ������ѡ�� y ��Ϊ 0 �ĵ�
    d = Abs(A * realPoint(index).X + B * realPoint(index).Y + C) / Sqr(A ^ 2 + B ^ 2)       '�㵽ֱ�߾���
    depth = HumanRadius - d
    If depth > 0 Then
        If realPoint(index).Y - d * Sin(AngleToRadian(MaxAngle / 2)) > 0 Then
            direction = -1 / Atn(k)       '��������Ǵ��ߵĽǶȣ�����ȡ���෴����
            calcForce.X = calcForce.X + Cos(direction) * WalkSpeed * depth * 2
            calcForce.Y = calcForce.Y + Sin(direction) * WalkSpeed * depth * 2
        End If
    End If
    '�����ұ߽磬һԪһ�η��̵�бʽתһ��ʽ�㷨
    k = Atn(AngleToRadian(90 - MaxAngle / 2))
    A = k
    B = -1
    C = -k * (PsgwayWidth / 2) + 0    ' C = -ka + b ������ѡ�� y ��Ϊ 0 �ĵ�
    d = Abs(A * realPoint(index).X + B * realPoint(index).Y + C) / Sqr(A ^ 2 + B ^ 2)       '�㵽ֱ�߾���
    depth = HumanRadius - d
    If depth > 0 Then
        If realPoint(index).Y - d * Sin(AngleToRadian(MaxAngle / 2)) > 0 Then
            direction = 1 / Atn(k)     '��������Ǵ��ߵĽǶȣ�����ȡ�˵��෴������������߷������������෴�ģ����Է���һ��
            calcForce.X = calcForce.X + Cos(direction) * WalkSpeed * depth * 2
            calcForce.Y = calcForce.Y + Sin(direction) * WalkSpeed * depth * 2
        End If
    End If
End Function

Private Function walkForward(ByVal index As Integer) As POINT
    Dim direction As Double
    direction = Atn(realPoint(index).Y / realPoint(index).X)
    If realPoint(index).X > 0 Then direction = direction + PI  'arctan Ҫ������ʹ��
    'Debug.Print RadianToAngle(direction)
    walkForward.X = walkForward.X + Cos(direction) * WalkSpeed
    walkForward.Y = walkForward.Y + Sin(direction) * WalkSpeed
End Function

Private Sub Mover_Timer()
    Dim deltaTime As Long               '����ƽ�� fps �������ٶȲ���
    deltaTime = GetTickCount - lastTime
    If deltaTime < 16 Then Exit Sub     '��������֡��
    Dim speedMultiply As Single
    speedMultiply = deltaTime / 16.6667 '�� 60 fps Ϊ��׼
    Static deltaTimeSum As Long
    If deltaTimeSum >= 333 Then
        fps = "fps: " & Round(1000 / deltaTime, 1) & "  speedMultiply: " & Round(speedMultiply, 1) & "��"
        If speedMultiply >= 4 Then fps.ForeColor = vbRed Else fps.ForeColor = vbBlack
        deltaTimeSum = 0
    Else
        deltaTimeSum = deltaTimeSum + deltaTime
    End If
    lastTime = GetTickCount
    ReDim nextPoint(UBound(realPoint)) As POINT
    For i = 1 To UBound(realPoint)
        If realPoint(i).Y > 0 Then
            Dim movement As POINT
            movement = calcForce(i)
            nextPoint(i).X = realPoint(i).X + movement.X * speedMultiply  '�� 60 fps Ϊ��׼
            nextPoint(i).Y = realPoint(i).Y + movement.Y * speedMultiply
            movement = walkForward(i)
            nextPoint(i).X = nextPoint(i).X + movement.X
            nextPoint(i).Y = nextPoint(i).Y + movement.Y
        Else                        '��������
            nextPoint(i).Y = realPoint(i).Y - WalkSpeed
            nextPoint(i).X = realPoint(i).X
        End If
    Next
    For i = 1 To UBound(realPoint)
        realPoint(i) = nextPoint(i)
    Next
    refreshDisplay
    'Debug.Print "========================="
End Sub


