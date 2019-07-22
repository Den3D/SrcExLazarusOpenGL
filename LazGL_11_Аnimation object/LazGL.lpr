program LazGL;

{$mode objfpc}{$H+}

uses
  gl, glu, glut;

const
  AppWidth = 640;
  AppHeight = 480;

var
  ScreenWidth, ScreenHeight : Integer;
  r  : Single;
  r1 : Single;
  b  : Boolean;

//****************************************************//
//***  Инициализация ресурсов приложения и OpenGL  ***//
//****************************************************//
procedure InitScene;
begin
  glClearColor(0.0, 0.0, 0.0, 0.0);

  glEnable(GL_DEPTH_TEST);
  // glDepthFunc(GL_LEQUAL);
  // glDepthRange(0.0, 1.0);
  // glDepthMask(GL_TRUE);
  // glClearDepth(1.0);
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

  glTranslatef(0.0, 0.0, 0.0);
  glRotatef(r, 0.0, 0.0, 1.0);
  glScalef(1.0, 1.0, 1.0);

  glBegin(GL_TRIANGLES);
    glVertex3f( 0.0, 1.5, 0.0);
    glVertex3f( 0.0, 0.0, 0.0);
    glVertex3f( 1.0, 0.0, 0.0);
  glEnd;

  if ((r1 > 2)and(b = false)) then b := true;
  if ((r1 < 0)and(b = true )) then b := false;

  if (b = false) then r1 := r1 + 0.1;
  if (b = true ) then r1 := r1 - 0.1;


  r := r + 1.0;

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

  InitScene;

  glutDisplayFunc(@RenderScene);
  glutReshapeFunc(@Reshape);
  glutTimerFunc(40, @Timer, 0);

  glutMainLoop;
end.
