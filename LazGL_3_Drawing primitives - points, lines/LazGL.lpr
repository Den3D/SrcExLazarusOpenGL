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
end;

//****************************************************//
//***   Процедура отрисовки                        ***//
//***   Данная процедура вызывается каждый кадр    ***//
//****************************************************//
procedure RenderScene; cdecl;
begin
  glClear(GL.GL_COLOR_BUFFER_BIT);
  glPointSize(3.0);
  glLineWidth(3.0);

  glBegin(GL.GL_LINE_LOOP);
    glColor3f(1.0,0.0,0.0);
    glVertex2f(-0.5, 0.5);
    glColor3f(0.0,1.0,0.0);
    glVertex2f( 0.5, 0.5);
    glColor3f(0.0,0.0,1.0);
    glVertex2f( 0.5,-0.5);
    glColor3f(0.5,0.5,0.5);
    glVertex2f(-0.5,-0.5);
  glEnd();

  glFinish();
  glutPostRedisplay();
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
  glutInitDisplayMode(GLUT_RGBA);
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
