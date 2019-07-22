program LazGL;

{$mode objfpc}{$H+}

uses
  gl, glu, glut;

const
  AppWidth  = 600;
  AppHeight = 600;

// Описание направление движение
type
  Naprav = (UP, DOWN, LEFT, RIHT);

type
  Snake = record
    posX : integer;
    posY : integer;
  end;

type
  Apple = record
    posX    : integer;
    posY    : integer;
    visible : boolean;
  end;

const
  Key_W = 119;
  Key_S = 115;
  Key_A = 97;
  Key_D = 100;
  Key_ESC = 27;

var
  ScreenWidth, ScreenHeight : Integer;
  step : integer;
  countSnake : integer;
  el : array[1..100] of Snake;
  vecSnake : Naprav;
  app : Apple;
  rnd : integer;

//***********************************//
//  Начальные характеристики змейки  //
//***********************************//
procedure StartGames();
begin
  countSnake := 3;
  vecSnake   := UP;
  step := 20;

  el[1].posX := 10 * step;
  el[1].posY := 2 * step;

  el[2].posX := 10 * step;
  el[2].posY := 1 * step;

  el[3].posX := 10 * step;
  el[3].posY := 0 * step;
end;

//------------------------------------------------//
//---   Процедура создания яблока на поле      ---//
//------------------------------------------------//
procedure CreateApple(value: integer);  cdecl;
var
 x, y : integer;
begin
  Randomize;
  x := Random(ScreenWidth div step);
  y := Random(ScreenHeight div step);
  app.posX := x * step;
  app.posY := y * step;
  app.visible := true;
end;

//****************************************************//
//*******        Создание сетки               ********//
//****************************************************//
procedure DrawGrid();
var
  i, j : integer;
begin
  glPushMatrix();
    glColor3f(0.0, 0.0, 0.0);
    glBegin(GL_LINES);

      for i:= 0 to (ScreenWidth div step) do begin
        glVertex2f(i*step, 0);
        glVertex2f(i*step, ScreenHeight);
      end;

      for j:= 0 to (ScreenHeight div step) do begin
        glVertex2f(0, j*step);
        glVertex2f(ScreenWidth, j*step);
      end;

    glEnd();
  glPopMatrix();
end;

procedure DrawQuad(mode : integer);
begin
  glBegin(mode);
    glVertex2f(0, step);
    glVertex2f(0, 0);
    glVertex2f(step, 0);
    glVertex2f(step, step);
  glEnd;
end;

//****************************************************//
//***  Инициализация ресурсов приложения и OpenGL  ***//
//****************************************************//
procedure InitScene;
begin
  glClearColor(0.3, 0.7, 0.9, 1.0);
  glEnable(GL_DEPTH_TEST);
  StartGames();
end;

//****************************************************//
//***   Процедура отрисовки                        ***//
//***   Данная процедура вызывается каждый кадр    ***//
//****************************************************//
procedure RenderScene; cdecl;
var
  i : Integer;
begin
  glLoadIdentity();
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  //DrawGrid();

  if (app.visible) then
  begin
    glPushMatrix();
      glColor3f(1.0, 0.0, 0.0);
      glTranslatef(app.posX, app.posY, 0.000);
      DrawQuad(GL_QUADS);
    glPopMatrix();
  end;

  for i:= 1 to countSnake do
  begin
    glPushMatrix;
      glColor3f(1.0, 1.0, 1.0);
      glTranslatef(el[i].posX, el[i].posY, 0.001);
      DrawQuad(GL_QUADS);
    glPopMatrix;

    glPushMatrix;
      glColor3f(0.0, 0.0, 0.0);
      glTranslatef(el[i].posX, el[i].posY, 0.002);
      DrawQuad(GL_LINE_LOOP);
    glPopMatrix;
  end; // snake

  glutSwapBuffers;
  glutPostRedisplay();
end;

//****************************************************//
//***  Процедура перенастройки                     ***//
//***  Проц. вызыв. при изменении размера экрана   ***//
//****************************************************//
procedure Reshape(Width, Height: Integer); cdecl;
begin
  ScreenHeight := Height;
  ScreenWidth  := Width;
  glViewport(0,0, Width, Height);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluOrtho2D(0, Width, 0, Height);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;


//****************************************************//
//****   Процедура обработки нажатия клавишь      ****//
//****************************************************//
procedure pressKey ( key : byte; x, y : integer );  cdecl;
begin
 case key of
  Key_W  : if not(vecSnake = DOWN ) then  vecSnake := UP;
  Key_S  : if not(vecSnake = UP )   then  vecSnake := DOWN;
  Key_A  : if not(vecSnake = RIHT ) then  vecSnake := LEFT;
  Key_D  : if not(vecSnake = LEFT ) then  vecSnake := RIHT;
  Key_ESC : halt;
 end;
end;

//------------------------------------------------//
//---  Обработка столкновении головы с яблоком ---//
//------------------------------------------------//
function isCollisionApple():boolean;
begin
  if ((el[1].posX = app.posX)and(el[1].posY = app.posY)) then
    isCollisionApple := true else isCollisionApple:= false;
end;

//------------------------------------------------//
//-  Функция таймер, обработка событий на сцене  -//
//------------------------------------------------//
procedure Update(value : integer);  cdecl;
var
  i : integer;
begin

  for i := 2 to countSnake do
    if ((el[1].posX = el[i].posX) and (el[1].posY = el[i].posY)) then
      StartGames();

  // проверка на столкновение змейки и яблока
  if ( isCollisionApple() and (app.visible)) then
  begin
    app.visible := false;
    countSnake := countSnake + 1;
    glutTimerFunc (7000, @CreateApple, 0);
  end;

  // перемещаем записи в массиве
  for i:= countSnake downto 2 do
  begin
    el[i].posY := el[i-1].posY;
    el[i].posX := el[i-1].posX;
  end;

  // перемещаем голову змеи
  case (vecSnake) of
   UP   : el[1].posY += step;
   DOWN : el[1].posY -= step;
   RIHT : el[1].posX += step;
   LEFT : el[1].posX -= step;
  end;

  // Следим за границами экрана
  if ( el[1].posX > ScreenWidth  ) then el[1].posX := 0;
  if ( el[1].posX < 0      ) then el[1].posX := ScreenWidth;
  if ( el[1].posY > ScreenHeight ) then el[1].posY := 0;
  if ( el[1].posY < 0      ) then el[1].posY := ScreenHeight;

  glutTimerFunc(600, @Update, 0);
end;


//****************************************************//
//***  Главная программа                           ***//
//***  Создание окна и передача процедуры рендера  ***//
//****************************************************//
begin
  glutInit(@argc,argv);
  glutInitDisplayMode(GLUT_RGBA or GLUT_DOUBLE or GLUT_DEPTH);
  glutInitWindowSize(AppWidth, AppHeight);
  ScreenWidth := glutGet(GLUT_SCREEN_WIDTH);
  ScreenHeight := glutGet(GLUT_SCREEN_HEIGHT);
  glutInitWindowPosition((ScreenWidth - AppWidth) div 2, (ScreenHeight - AppHeight) div 2);
  glutCreateWindow('Lazarus OpenGL Tutorial');

  glutKeyboardFunc ( @pressKey );

  InitScene;

  glutDisplayFunc(@RenderScene);
  glutReshapeFunc(@Reshape);

  glutTimerFunc(600, @Update, 0);
  glutTimerFunc(600, @CreateApple, 0);

  glutMainLoop;
end.
