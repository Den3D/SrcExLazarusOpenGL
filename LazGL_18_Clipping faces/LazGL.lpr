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
  glColor3f(1.0, 0.0, 0.0);
  glBegin(GL.GL_QUADS);
    glVertex3f( -2.0,  2.0,  2.0); // 1
    glVertex3f( -2.0, -2.0,  2.0); // 2
    glVertex3f(  2.0, -2.0,  2.0); // 3
    glVertex3f(  2.0,  2.0,  2.0); // 4
  glEnd;

  // back
  glColor3f(0.0, 1.0, 0.0);
  glBegin(GL.GL_QUADS);
    glVertex3f( -2.0,  2.0, -2.0); // 5
    glVertex3f( -2.0, -2.0, -2.0); // 6
    glVertex3f(  2.0, -2.0, -2.0); // 7
    glVertex3f(  2.0,  2.0, -2.0); // 8
  glEnd;

  // left
  glColor3f(0.0, 0.0, 1.0);
  glBegin(GL.GL_QUADS);
    glVertex3f( -2.0,  2.0, -2.0); // 5
    glVertex3f( -2.0, -2.0, -2.0); // 6
    glVertex3f( -2.0, -2.0,  2.0); // 2
    glVertex3f( -2.0,  2.0,  2.0); // 1
  glEnd;

  // right
  glColor3f(1.0, 1.0, 0.0);
  glBegin(GL.GL_QUADS);
    glVertex3f(  2.0, -2.0, -2.0); // 7
    glVertex3f(  2.0,  2.0, -2.0); // 8
    glVertex3f(  2.0,  2.0,  2.0); // 4
    glVertex3f(  2.0, -2.0,  2.0); // 3
  glEnd;

  // top
  glColor3f(1.0, 0.0, 1.0);
  glBegin(GL.GL_QUADS);
    glVertex3f( -2.0,  2.0,  2.0); // 1
    glVertex3f(  2.0,  2.0,  2.0); // 4
    glVertex3f(  2.0,  2.0, -2.0); // 8
    glVertex3f( -2.0,  2.0, -2.0); // 5
  glEnd;

  // down
  glColor3f(0.5, 0.0, 0.5);
  glBegin(GL.GL_QUADS);
    glVertex3f(  2.0, -2.0,  2.0); // 3
    glVertex3f( -2.0, -2.0,  2.0); // 2
    glVertex3f( -2.0, -2.0, -2.0); // 6
    glVertex3f(  2.0, -2.0, -2.0); // 7
  glEnd;
end;


procedure AAA;
begin
  GL.glColor3f(1.0, 0.0, 0.0);
  GL.glBegin(GL.GL_QUADS);
    gl.glVertex3f( -2.0,  2.0,  2.0); // 1
    gl.glVertex3f( -2.0, -2.0,  2.0); // 2
    gl.glVertex3f(  2.0, -2.0,  2.0); // 3
    gl.glVertex3f(  2.0,  2.0,  2.0); // 4
  GL.glEnd();
end;

//****************************************************//
//*******      Процедура создания Human     **********//
//****************************************************//
procedure DrawHuman();
begin
  // тело 1-2
  glPushMatrix;
    // 1
    glPushMatrix;
    glTranslatef(0.0, 0.0, 0.0);
    glColor3f(0.9, 0.1, 0.6);
    glutSolidCube(1.0);
    glPopMatrix;

    // 2
    glPushMatrix;
    glTranslatef(0.0, -1.0, 0.0);
    glColor3f(0.9, 0.1, 0.6);
    glutSolidCube(1.0);
    glPopMatrix;

  glPopMatrix; // 1-2

    // пр. рука
    glPushMatrix;
    glColor3f(0.9, 0.6, 0.6);
    glTranslatef(1.0, 0.0, 0.0);
    glutSolidCube(1.0);
    glPopMatrix;

    // лев. рука
    glPushMatrix;
    glColor3f(0.9, 0.6, 0.1);
    glTranslatef(-1.0, 0.0, 0.0);
    glutSolidCube(1.0);
    glPopMatrix;

    // голова
    glPushMatrix;
    glColor3f(0.1, 0.6, 0.1);
    glTranslatef(0.0, 1.0, 0.0);
    glutSolidCube(1.0);
    glPopMatrix;
end;

//****************************************************//
//***  Инициализация ресурсов приложения и OpenGL  ***//
//****************************************************//
procedure InitScene;
begin
  glClearColor(0.0, 0.0, 0.0, 0.0);

  glEnable(GL_DEPTH_TEST);
  // glEnable(GL_CULL_FACE);
  // glCullFace(GL_BACK);
  // glFrontFace(GL_CW);

  glPolygonMode(GL_FRONT, GL_LINE);

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
   glTranslatef(0, 0, 0);
   glRotatef(posY,0.0, 1.0, 0.0);
     //DrawHuman();
   AAA;
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
  //Key_W  : posY := posY + 1.0;
  //Key_S  : posY := posY - 1.0;
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
  glutInitWindowSize(AppWidth, AppHeight);
  ScreenWidth := glutGet(GLUT_SCREEN_WIDTH);
  ScreenHeight := glutGet(GLUT_SCREEN_HEIGHT);
  glutInitWindowPosition((ScreenWidth - AppWidth) div 2, (ScreenHeight - AppHeight) div 2);
  glutCreateWindow('Lazarus OpenGL Tutorial');

  glutKeyboardFunc ( @pressKey );

  InitScene;

  glutDisplayFunc(@RenderScene);
  glutReshapeFunc(@Reshape);
  glutTimerFunc(40, @Timer, 0);

  glutMainLoop;
end.
