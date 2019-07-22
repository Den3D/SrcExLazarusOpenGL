program LazGL;

{$mode objfpc}{$H+}

uses
  gl, glu, glut;

const
  AppWidth = 640;
  AppHeight = 480;

var
  ScreenWidth, ScreenHeight : Integer;
  r : Single;

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
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glRotatef(r, 0.0, 1.0, 0.0);
  glBegin(GL_TRIANGLES);
    glColor3f (1.0,   0.0, 0.0);
    glVertex3f(-0.9,  0.9, 0.0);
    glVertex3f(-0.9, -0.9, 0.0);
    glVertex3f( 0.9, -0.9, 0.0);

    glColor3f ( 0.0,  1.0, 0.5);
    glVertex3f( 0.9,  0.9, 0.5);
    glVertex3f( 0.9, -0.9, 0.5);
    glVertex3f(-0.9, -0.9, -0.5);
  glEnd;

  r := r + 0.03;

  glutSwapBuffers;
  glutPostRedisplay;
end;

//****************************************************//
//***  Процедура перенастройки                     ***//
//***  Проц. вызыв. при изменении размера экрана   ***//
//****************************************************//
procedure Reshape(Width, Height: Integer); cdecl;
begin
  // ...
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

  glutMainLoop;
end.
