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
  if ( r >= 1.0) then r := 0.0;
  r := r + 0.001;
  glClearColor( r, 0.0, 0.0, 0.0);
  glClear(GL.GL_COLOR_BUFFER_BIT);

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
