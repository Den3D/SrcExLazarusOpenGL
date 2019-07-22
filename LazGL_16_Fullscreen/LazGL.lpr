program LazGL;

{$mode objfpc}{$H+}

uses
  gl, glu, glut;

const
  AppWidth  = 640;
  AppHeight = 480;

const
  Key_W = 119;
  Key_S = 115;
  Key_A = 97;
  Key_D = 100;
  Key_ESC = 27;

var
  ScreenWidth, ScreenHeight : Integer;
  posX : Single;
  posY : Single;
  posZ : Single;

//****************************************************//
//*******      Процедура создания куба      **********//
//****************************************************//
procedure DrawCube();
begin
  // front
  GL.glColor3f(1.0, 0.0, 0.0);
  GL.glBegin(GL.GL_QUADS);
    gl.glVertex3f( -2.0,  2.0,  2.0); // 1
    gl.glVertex3f( -2.0, -2.0,  2.0); // 2
    gl.glVertex3f(  2.0, -2.0,  2.0); // 3
    gl.glVertex3f(  2.0,  2.0,  2.0); // 4
  GL.glEnd();

  // back
  GL.glColor3f(0.0, 1.0, 0.0);
  GL.glBegin(GL.GL_QUADS);
    gl.glVertex3f( -2.0,  2.0, -2.0); // 5
    gl.glVertex3f( -2.0, -2.0, -2.0); // 6
    gl.glVertex3f(  2.0, -2.0, -2.0); // 7
    gl.glVertex3f(  2.0,  2.0, -2.0); // 8
  GL.glEnd();

  // left
  GL.glColor3f(0.0, 0.0, 1.0);
  GL.glBegin(GL.GL_QUADS);
    gl.glVertex3f( -2.0,  2.0, -2.0); // 5
    gl.glVertex3f( -2.0, -2.0, -2.0); // 6
    gl.glVertex3f( -2.0, -2.0,  2.0); // 2
    gl.glVertex3f( -2.0,  2.0,  2.0); // 1
  GL.glEnd();

  // right
  GL.glColor3f(1.0, 1.0, 0.0);
  GL.glBegin(GL.GL_QUADS);
    gl.glVertex3f(  2.0, -2.0, -2.0); // 7
    gl.glVertex3f(  2.0,  2.0, -2.0); // 8
    gl.glVertex3f(  2.0,  2.0,  2.0); // 4
    gl.glVertex3f(  2.0, -2.0,  2.0); // 3
  GL.glEnd();

  // top
  GL.glColor3f(1.0, 0.0, 1.0);
  GL.glBegin(GL.GL_QUADS);
    gl.glVertex3f( -2.0,  2.0,  2.0); // 1
    gl.glVertex3f(  2.0,  2.0,  2.0); // 4
    gl.glVertex3f(  2.0,  2.0, -2.0); // 8
    gl.glVertex3f( -2.0,  2.0, -2.0); // 5
  GL.glEnd();

  // down
  GL.glColor3f(0.5, 0.0, 0.5);
  GL.glBegin(GL.GL_QUADS);
    gl.glVertex3f(  2.0, -2.0,  2.0); // 3
    gl.glVertex3f( -2.0, -2.0,  2.0); // 2
    gl.glVertex3f( -2.0, -2.0, -2.0); // 6
    gl.glVertex3f(  2.0, -2.0, -2.0); // 7
  GL.glEnd();
end;

//****************************************************//
//*******      Процедура создания Human     **********//
//****************************************************//

procedure DrawHuman();
begin

    // тело 1-2
    GL.glPushMatrix();
     // 1
     GL.glPushMatrix();
       GL.glTranslatef(0.0, 0.0, 0.0);
       GL.glColor3f(0.9, 0.1, 0.6);
       GLUT.glutSolidCube(1.0);
     GL.glPopMatrix();
     // 2
     GL.glPushMatrix();
       GL.glTranslatef(0.0, -1.0, 0.0);
       GL.glColor3f(0.9, 0.1, 0.6);
       GLUT.glutSolidCube(1.0);
     GL.glPopMatrix();

     GL.glPopMatrix(); // 1-2

    // пр. рука
    GL.glPushMatrix();
    GL.glColor3f(0.9, 0.6, 0.6);
    GL.glTranslatef(1.0, 0.0, 0.0);
    GLUT.glutSolidCube(1.0);
    GL.glPopMatrix();

    // лев. рука
    GL.glPushMatrix();
    GL.glColor3f(0.9, 0.6, 0.1);
    GL.glTranslatef(-1.0, 0.0, 0.0);
    GLUT.glutSolidCube(1.0);
    GL.glPopMatrix();

    // голова
    GL.glPushMatrix();
    GL.glColor3f(0.1, 0.6, 0.1);
    GL.glTranslatef(0.0, 1.0, 0.0);
    GLUT.glutSolidCube(1.0);
    GL.glPopMatrix();
end;

//****************************************************//
//***  Инициализация ресурсов приложения и OpenGL  ***//
//****************************************************//
procedure InitScene;
begin
  glClearColor(0.0, 0.0, 0.0, 0.0);

  glEnable(GL_DEPTH_TEST);

end;

//****************************************************//
//***   Процедура отрисовки                        ***//
//***   Данная процедура вызывается каждый кадр    ***//
//****************************************************//
procedure RenderScene; cdecl;
begin
  glLoadIdentity();
  gluLookAt( 0.0, 0.0, 10.0,
             0.0, 1.0,  0.0,
             0.0, 1.0,  0.0);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glPushMatrix();
  glTranslatef(posX, posY, posZ);
    DrawHuman();
  glPopMatrix();

  glutSwapBuffers;
  //glutPostRedisplay;
end;

//****************************************************//
//***  Процедура перенастройки                     ***//
//***  Проц. вызыв. при изменении размера экрана   ***//
//****************************************************//
procedure Reshape(Width, Height: Integer); cdecl;
begin
  glViewport(0,0, Width, Height);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;

  gluPerspective(45, Width / Height, 0.1, 10000.0);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;

//****************************************************//
//*** Процедура таймер.                            ***//
//*** Вызывается каждые 40 мсек для отрисовка кадра **//
//****************************************************//
procedure Timer(val: integer); cdecl;
begin
  glutPostRedisplay();
  glutTimerFunc(40, @Timer, 0);
end;


procedure pressKey ( key : byte; x, y : integer );   cdecl;
var
 ch : char;
begin
 case key of
  Key_W  : posY := posY + 1.0;
  Key_S  : posY := posY - 1.0;
  Key_A  : posX := posX - 1.0;
  Key_D  : posX := posX + 1.0;
  Key_ESC : halt;
 end;
end;


//****************************************************//
//***  Главная программа                           ***//
//***  Создание окна и передача процедуры рендера  ***//
//****************************************************//
begin
  glutInit(@argc,argv);
  glutInitDisplayMode(GLUT_RGBA or GLUT_DOUBLE or GLUT_DEPTH);
  // glutInitWindowSize(AppWidth, AppHeight);
  // ScreenWidth := glutGet(GLUT_SCREEN_WIDTH);
  // ScreenHeight := glutGet(GLUT_SCREEN_HEIGHT);
  // glutInitWindowPosition((ScreenWidth - AppWidth) div 2, (ScreenHeight - AppHeight) div 2);
  // glutCreateWindow('Lazarus OpenGL Tutorial');

  glutGameModeString(':32');

  if (glutGameModeGet(GLUT_GAME_MODE_POSSIBLE)<>0) then
      glutEnterGameMode() else glutLeaveGameMode();


  glutKeyboardFunc ( @pressKey );

  InitScene;

  glutDisplayFunc(@RenderScene);
  glutReshapeFunc(@Reshape);
  glutTimerFunc(40, @Timer, 0);

  glutMainLoop;
end.
