unit Unit111;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TForm1 = class(TForm)
    pb1: TPaintBox;
    function MulMatrix(a,b:Matrix):Matrix;
    function P3MulMatrix(P:TPoint3D; A:Matrix):TPoint;
    function MatrixS(X, Y, Z:real):Matrix;
    function MatrixPz(C:real):Matrix;
    function MatrixRx(f:real):Matrix;
    function MatrixRz(f:Single):Matrix;
    procedure Draw;
  private
  public
  end;

  Matrix = array [0..3, 0..3] of real;

  TPoint3D = record
    x, y, z, w : integer;
  end;

var
  Form4: TForm4;
  RMatrix: Matrix;

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
procedure Points3DtoPoints2D(P3:array of TPoint3D; var P2:array of TPoint);
var a,b:Matrix;
begin

  a:=MatrixS(1.3,1.3,1.3);      //Масштабирование
  a:=MulMatrix(a,MainMatrix);  //Применение матрицы поворота
  b:=MatrixPz(500);            //Перспектива
  a:=MulMatrix(a,b);

  for i := low(list1) to High(list1) do
    begin
      P2[i]:=P3MulMatrix(P3[i],a);
      P2[i].x:=P2[i].x + 250;
      P2[i].y:=P2[i].y + 250;
    end;
end;

//Умножение матриц
function TForm1.MulMatrix(a,b:Matrix):Matrix;
begin
  for i:=0 to 3 do
    for j:=0 to 3 do
      Result[i,j]:=a[1,j]*b[i,1]+a[2,j]*b[i,2]+a[3,j]*b[i,3]+a[4,j]*b[i,4];
end;

// Умножение точки на матрицу
function TForm1.P3MulMatrix(P:TPoint3D; A:Matrix):TPoint;
var t:real;
begin
   t:=P.X*A[4,1]+P.Y*A[4,2]+P.Z*A[4,3]+P.t*A[4,4];
   Result.X:=trunc((P.X*A[1,1]+P.Y*A[1,2]+P.Z*A[1,3]+P.t*A[1,4])/t);
   Result.Y:=trunc((P.X*A[2,1]+P.Y*A[2,2]+P.Z*A[2,3]+P.t*A[2,4])/t);
end;

function TForm1.MatrixS(X, Y, Z:real):Matrix;
var a:Matrix;                           //масштабирование
begin
   a[0,0]:=X; //  X, 0, 0, 0,
   a[1,1]:=Y; //  0, Y, 0, 0,
   a[2,2]:=Z; //  0, 0, Z, 0,
   a[3,3]:1;  //  0, 0, 0, 1
   Result:=a;
end;

function TForm1.MatrixPz(C:real):Matrix;       //перспектива
var a:Matrix;
begin
   a[0,0]:=1; //  1, 0, 0,   0,
   a[1,1]:=1; //  0, 1, 0,   0,
   a[2,2]:=1; //  0, 0, 1,  -1/c,
   a[3,3]:=3  //  0, 0, 0,   1
   a[2,3]:=-1/c;
   Result:=a;
end;

function TForm1.MatrixRx(f:real):Matrix;       //поворот по х
var a:Matrix;
begin
   a[0,0]:=1;       // 1,      0 ,     0 ,  0,
   a[1,1]:=cos(f);  // 0,  cos(f), sin(f),  0,
   a[2,2]:=cos(f);  // 0, -sin(f), cos(f),  0,
   a[1,2]:=sin(f);  // 0,      0 ,     0 ,  1
   a[2,1]:=sin(f);
   a[3,3]:=1;
   Result:=a;
end;

function TForm1.MatrixRz(f:Single):Matrix;      //поворот по z
var a:Matrix;
begin
   a[0,0]:=cos(f);  //  cos(f), sin(f), 0, 0,
   a[1,1]:=cos(f);  // -sin(f), cos(f), 0, 0,
   a[2,2]:=1;       //      0 ,     0 , 1, 0,
   a[3,3]:=1;       //      0 ,     0 , 0, 1
   a[0,1]:=sin(f);
   a[1,0]:=-sin(f);
   Result:=a;
end;

procedure TForm1.Draw;
var P : array [0..7] of TPoint;
    i:integer;
begin
   Points3ToPoints2D(Points3D, P);

   pb1.Canvas.brush.Color := clWhite;
   pb1.Canvas.fillRect(Rect(0, 0, image1.Width, image1.Height));

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


end.
 
