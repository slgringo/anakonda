unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    ComboBox1: TComboBox;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    LabeledEdit1: TLabeledEdit;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure ComboBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ComboBox1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

  TBlock = record
    x : integer;
    y : integer;
    dir:integer;
    olddir:integer;
  end;

var
  Form1: TForm1;
  state : integer = 0;
  direction : integer;
  snake:array of TBlock;
  freeblocks:array of TBlock;
  score : integer;
  itemInd:Integer;

  procedure renderSnake (fill:boolean);

implementation

{$R *.lfm}

function isPlaceFree(x,y:integer):boolean;
var
  i:integer;
begin
  if (x=9) and (y=0) then begin
    result:=false;
    exit;
  end;
  for i:=0 to length(freeblocks)-1 do begin
    if (x=freeblocks[i].x) and (y=freeblocks[i].y) then begin
    result:=false;
    exit;
  end;
  end;
  result:=true;
end;

procedure addFreeBlocks(count:integer);
var
  i:integer;
  x,y:integer;
begin
  for i:=0 to count-1 do begin
    randomize;
    repeat
      x:=random(20);
      y:=random(20);
    until isPlaceFree(x,y)=true;
    setlength(freeblocks,i+1);
    freeblocks[i].x:=x;
    freeblocks[i].y:=y;
  end;
end;

procedure initNewGame;
var
  blockcount:integer;
begin
  state:=1;
  Form1.Image1.Canvas.Brush.Color:=clWhite;
  Form1.Image1.Canvas.FillRect(0,0, 400, 400);
  score := 0;
  Form1.LabeledEdit1.Text:='';
  direction := 3;
  Setlength(snake, 1);
  snake[0].x:=9;
  snake[0].y:=0;
  snake[0].dir:=direction;
  snake[0].olddir:=direction;
  renderSnake(true);
  case form1.ComboBox1.ItemIndex of
    0: begin
      blockcount := 20;
    end;
    1: begin
      blockcount := 10;
    end;
    2: begin
      blockcount := 30;
    end;
  end;
  addFreeBlocks(blockcount);
  itemInd:=Form1.ComboBox1.ItemIndex;
end;

procedure renderBlock(block: TBlock; fill : boolean);
var
  color:tcolor;
  rect:Trect;
begin
  if fill=true then color:= clGray
  else color:=clWhite;
  Form1.Image1.Canvas.Brush.Color:=color;
  rect.Left:=block.x * 20;
  rect.Top:=block.y * 20;
  rect.Right:=block.x * 20 + 20;
  rect.Bottom:=block.y * 20 + 20;
  Form1.Image1.Canvas.Fillrect(rect);
end;

procedure renderSnake (fill:boolean);
var
  i:integer;
begin
  for  i:=0 to length(snake) - 1 do begin
    renderBlock(snake[i], fill);
  end;
end;

procedure renderFreeBlocks (fill:boolean);
var
  i:integer;
begin
  for  i:=0 to length(freeblocks) - 1 do begin
    renderBlock(freeblocks[i], fill);
  end;
end;

function getDirVec(dir : integer):TPoint;
var
  dx, dy:integer;
begin
  case dir of
    0: begin
      dx:=-1;
      dy:=0;
    end;
    1: begin
      dx:=0;
      dy:=-1;
    end;
    2: begin
      dx:=1;
      dy:=0;
    end;
    3: begin
      dx:=0;
      dy:=1;
    end;
  end;
  result.x := dx;
  result.y := dy;
end;

procedure moveBlock(var block:Tblock);
var
  d : TPoint;
  i:integer;
begin
  d := getDirVec(block.dir);
  block.x:=block.x+d.x;
  block.y:=block.y+d.y;
end;

procedure checkBlocks(forward:boolean);
var
  nxt, nxt2:Tpoint;
  i:integer;
begin
  nxt.x:=0;
  nxt.y:=0;
  nxt2.x:=0;
  nxt2.y:=0;
  if forward=true then begin
    nxt:= getDirVec(snake[length(snake)-1].dir);
  end
  else begin
    nxt2:=getDirVec(snake[length(snake)-1].dir);
  end;
  nxt.x:=nxt.x+snake[length(snake)-1].x;
  nxt.y:=nxt.y+snake[length(snake)-1].y;
  for i:=0 to length(freeblocks)-1 do begin
    if (freeblocks[i].x=nxt.x) and (freeblocks[i].y=nxt.y) then begin
      setlength(snake, length(snake)+1);
      snake[length(snake)-1].x := freeblocks[i].x + nxt2.x;
      snake[length(snake)-1].y := freeblocks[i].y + nxt2.y;
      snake[length(snake)-1].dir:=snake[length(snake)-2].dir;
      freeblocks[i].x:=-10;
      score:=score+100;
      Form1.LabeledEdit1.Text:=intToStr(score);
      exit;
    end;
  end;
end;

procedure moveSnake();
var
  i:integer;
  oldDir:integer;
begin
  for i:= length(snake) -1 downto 0 do begin
    snake[i].oldDir:=snake[i].dir;
    if (i=length(snake) -1)  then begin
      snake[i].dir:=direction;
    end;
    if (i<>length(snake) -1)  then begin
      snake[i].dir:=snake[i+1].oldDir;
    end;
    moveBlock(snake[i]);
  end;
end;

function checkCollisions : boolean;
var
  i, j:integer;
begin
  result:=false;
  for i:=0 to length(snake) - 1 do begin
    if (snake[i].x > 19) or (snake[i].x < 0) or (snake[i].y > 19) or (snake[i].y < 0) then begin
      result:=true;
      exit;
    end;
    for j:=0 to length(snake) -1 do begin
      if (i<>j) and (snake[i].x = snake[j].x) and (snake[i].y=snake[j].y) then begin
        result:=true;
      exit;
      end;
    end;
  end;
end;

procedure setGameOverState;
begin
  state:=2;
  Form1.Image1.Canvas.TextOut(150, 190, 'Game over');
end;

procedure setWinState;
begin
  state:=3;
  Form1.Image1.Canvas.TextOut(150, 190, 'Epic win');
end;

procedure updateRunning;
begin
  renderSnake(false);
  renderFreeBlocks(false);
  moveSnake;
  renderFreeBlocks(true);
  renderSnake(true);
  checkblocks(true);
  checkblocks(false);
  if checkCollisions = true then
  begin
    setGameOverState;
  end;
  if score div length(freeBlocks)=100 then begin
    setWinState;
  end;
end;

procedure updateGame();
begin
  case state of
    0: begin   //game over

    end;
    1 : begin //running
      updateRunning;
    end;
    2: begin

    end;
  end;
end;

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  initNewGame;
end;

procedure TForm1.ComboBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TForm1.ComboBox1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if form1.ComboBox1.ItemIndex <> itemInd then begin
    form1.ComboBox1.ItemIndex:=itemInd;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Image1.Canvas.FillRect(0,0, 400, 400);
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  if form1.ComboBox1.ItemIndex <> itemInd then begin
    form1.ComboBox1.ItemIndex:=itemInd;
  end;
  case key of
    37: begin
      direction:=0;
    end;
    38: begin
      direction:=1;
    end;
    39: begin
      direction:=2;
    end;
    40: begin
      direction:=3;
    end;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  updateGame;
end;

end.

