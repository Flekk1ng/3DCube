unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  Matrix = array [0..3, 0..3] of real;

  TPoint3D = record
    x, y, z, w : integer;
  end;

  TForm1 = class(TForm)
    pb1: TPaintBox;
    tmr1: TTimer;
    btn1: TButton;
    lbl1: TLabel;
    lbl2: TLabel;
    procedure Points3DtoPoints2D(P3:array of TPoint3D; var P2:array of TPoint);
    function MulMatrix(a,b:Matrix):Matrix;
    function P3MulMatrix(P:TPoint3D; A:Matrix):TPoint;
    function MatrixS(X, Y, Z:real):Matrix;
    function MatrixPz(C:real):Matrix;
    function MatrixRx(f:real):Matrix;
    function MatrixRz(f:real):Matrix;
    function MatrixRy(f:real):Matrix;
    procedure Draw;
    procedure tmr1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure pb1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
  public
  end;

var
  Form1: TForm1;
  MainMatrix: Matrix;
  x1,y1:integer;

const Points3D : array [0..7] of TPoint3D =
       ((x: 100; y: 100; z: 100; w:1), //0
        (x:-100; y: 100; z: 100; w:1), //1
        (x:-100; y:-100; z: 100; w:1), //2
        (x: 100; y:-100; z: 100; w:1), //3
        (x: 100; y: 100; z:-100; w:1), //4
        (x:-100; y: 100; z:-100; w:1), //5
        (x:-100; y:-100; z:-100; w:1), //6
        (x: 100; y:-100; z:-100; w:1));//7

implementation

{$R *.dfm}

{Создание матрицы поворота

 Преобразование 3д координат вершин куба 2д координаты и одновременно применение матрицы поворота
 }
 
//Преобразование 3д координат в 2д
procedure TForm1.Points3DtoPoints2D(P3:array of TPoint3D; var P2:array of TPoint);
var a,b:Matrix;
    i:integer;
begin

  a:=MatrixS(1.4, 1.4, 1.4);
  a:=MulMatrix(a,MainMatrix);
  
  b:=MatrixPz(500);
                              //Масштабирование
  a:=MulMatrix(a,b);  //Применение матрицы поворота
             //Перспектива


  for i:=low(P3) to High(P3) do
    begin
      P2[i]:=P3MulMatrix(P3[i],a);
      P2[i].x:=P2[i].x + 300;
      P2[i].y:=P2[i].y + 300;
    end;
end;

//Умножение матриц
function TForm1.MulMatrix(a,b:Matrix):Matrix;
var i,j:integer;
begin
  for i:=0 to 3 do
    for j:=0 to 3 do
      Result[i,j]:=a[0,j]*b[i,0]+a[1,j]*b[i,1]+a[2,j]*b[i,2]+a[3,j]*b[i,3];
end;

// Умножение матрицы на точку
function TForm1.P3MulMatrix(P:TPoint3D; A:Matrix):TPoint;
var w:real;
begin
   w:=P.X*A[3,0]+P.Y*A[3,1]+P.Z*A[3,2]+P.w*A[3,3];
   Result.X:=trunc((P.X*A[0,0]+P.Y*A[0,1]+P.Z*A[0,2]+P.w*A[0,3])/w);
   Result.Y:=trunc((P.X*A[1,0]+P.Y*A[1,1]+P.Z*A[1,2]+P.w*A[1,3])/w);
end;

function TForm1.MatrixS(X, Y, Z:real):Matrix;
var a:Matrix;
    i,j:integer;                           //масштабирование
begin
  for i:=0 to 3 do
    for j:=0 to 3 do
      a[i,j]:=0;
   a[0,0]:=X; //  X, 0, 0, 0,
   a[1,1]:=Y; //  0, Y, 0, 0,
   a[2,2]:=Z; //  0, 0, Z, 0,
   a[3,3]:=1;  //  0, 0, 0, 1
   Result:=a;
end;

function TForm1.MatrixPz(C:real):Matrix;       //перспектива
var a:Matrix;
    i,j:integer;
begin
  for i:=0 to 3 do
    for j:=0 to 3 do
      a[i,j]:=0;
   a[3,2]:=-1/c;
   a[0,0]:=1; //  1, 0, 0,   0,
   a[1,1]:=1; //  0, 1, 0,   0,
   a[2,2]:=1; //  0, 0, 1,  -1/c,
   a[3,3]:=1;  //  0, 0, 0,   1

   Result:=a;
end;

function TForm1.MatrixRx(f:real):Matrix;       //поворот по х
var a:Matrix;
    i,j:integer;
begin
   for i:=0 to 3 do
    for j:=0 to 3 do
      a[i,j]:=0;
   a[0,0]:=1;       // 1,      0 ,     0 ,  0,
   a[1,1]:=cos(f);  // 0,  cos(f), sin(f),  0,
   a[2,2]:=cos(f);  // 0, -sin(f), cos(f),  0,
   a[1,2]:=-sin(f);  // 0,      0 ,     0 ,  1
   a[2,1]:=sin(f);
   a[3,3]:=1;
   Result:=a;
end;

function TForm1.MatrixRz(f:real):Matrix;      //поворот по z
var a:Matrix;
    i,j:integer;
begin
  for i:=0 to 3 do
    for j:=0 to 3 do
      a[i,j]:=0;
   a[0,0]:=cos(f);  //  cos(f), sin(f), 0, 0,
   a[1,1]:=cos(f);  // -sin(f), cos(f), 0, 0,
   a[2,2]:=1;       //      0 ,     0 , 1, 0,
   a[3,3]:=1;       //      0 ,     0 , 0, 1
   a[0,1]:=-sin(f);
   a[1,0]:=sin(f);
   Result:=a;
end;

function TForm1.MatrixRy(f:real):Matrix;
var a:Matrix;
    i,j:integer;
begin
  for i:=0 to 3 do   //  cos(f), 0, sin(f), 0,
    for j:=0 to 3 do //      0 , 1,     0 , 0,
      a[i,j]:=0;     // -sin(f), 0, cos(f), 0,
                     //      0 , 0,     0 , 1
  a[0,0]:=cos(f);
  a[1,1]:=1;
  a[2,2]:=cos(f);
  a[3,3]:=1;
  a[0,2]:=sin(f);
  a[2,0]:=-sin(f);
  Result:=a;

end;

procedure TForm1.Draw;
var P : array [0..7] of TPoint;
    i:integer;
begin
   Points3DToPoints2D(Points3D, P);

   pb1.Canvas.brush.Color := clWhite;
   pb1.Canvas.fillRect(Rect(0, 0, pb1.Width, pb1.Height));

   pb1.Canvas.Pen.Color := clGreen;
   pb1.Canvas.MoveTo(P[0].x, P[0].y);
   pb1.Canvas.LineTo(P[1].x, P[1].y);
   pb1.Canvas.LineTo(P[2].x, P[2].y);
   pb1.Canvas.LineTo(P[3].x, P[3].y);
   pb1.Canvas.LineTo(P[0].x, P[0].y);

   pb1.Canvas.MoveTo(P[4].x, P[4].y);
   pb1.Canvas.LineTo(P[5].x, P[5].y);
   pb1.Canvas.LineTo(P[6].x, P[6].y);
   pb1.Canvas.LineTo(P[7].x, P[7].y);
   pb1.Canvas.LineTo(P[4].x, P[4].y);

   pb1.Canvas.MoveTo(P[1].x, P[1].y);
   pb1.Canvas.LineTo(P[5].x, P[5].y);
   pb1.Canvas.MoveTo(P[2].x, P[2].y);
   pb1.Canvas.LineTo(P[6].x, P[6].y);
   pb1.Canvas.MoveTo(P[3].x, P[3].y);
   pb1.Canvas.LineTo(P[7].x, P[7].y);
   pb1.Canvas.MoveTo(P[0].x, P[0].y);
   pb1.Canvas.LineTo(P[4].x, P[4].y);
end;


procedure TForm1.tmr1Timer(Sender: TObject);
var a,b,c:Matrix;
begin
  a:=MatrixRz(pi/36);
  b:=MatrixRx(pi/48);
  c:=MatrixRy(pi/36);
  a:=MulMatrix(a,b);
  a:=MulMatrix(a,c);
  MainMatrix:=MulMatrix(MainMatrix, a);
  Draw;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  MainMatrix:=MatrixRz(0);
  Draw;
  x1:=0;
  y1:=0;
end;

procedure TForm1.btn1Click(Sender: TObject);
var a,b:matrix;
begin
  if tmr1.Enabled then tmr1.Enabled:=False
  else tmr1.Enabled:=True;
end;

procedure TForm1.pb1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var w,val:integer;
    step:real;
    b:Matrix;
    fl:Boolean;
begin
  {w:=pb1.Width;
  step:=(2*pi)/(360*(w/20));
  val:=trunc(x/step);

  MainMatrix:=MatrixRx(0);
  b:=MatrixRx(val*step);
  MainMatrix:=MulMatrix(MainMatrix, b);
  Draw; }

  if x mod 20 = 0 then
    begin
      if x<x1 then
        begin

          b:=MatrixRy(pi/24);
          MainMatrix:=MulMatrix(MainMatrix, b);
          lbl1.Caption:=inttostr(x);
          lbl2.Caption:=inttostr(x1);

        end
      else
        if x>x1 then
          begin
          b:=MatrixRy(-pi/24);
          MainMatrix:=MulMatrix(MainMatrix, b);
          end;
      x1:=x;
    end;

    if y mod 20 = 0 then
    begin
      if y<y1 then
        begin

          b:=MatrixRx(pi/15);
          MainMatrix:=MulMatrix(MainMatrix, b);
          lbl1.Caption:=inttostr(x);
          lbl2.Caption:=inttostr(x1);

        end
      else
        if y>y1 then
          begin
          b:=MatrixRx(-pi/15);
          MainMatrix:=MulMatrix(MainMatrix, b);
          end;
      y1:=y;
    end;

    Draw;

end;

end.
 
