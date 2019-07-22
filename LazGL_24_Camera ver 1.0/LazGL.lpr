program LazGL;

{$mode objfpc}{$H+}

uses
  gl, glu, glut, GLext, sdl, sdl_image ;
// sdl - многофункциональная библиотека, в данном примере будет
// использоваться для загрузки изображений

// Для нормальной работы приложения необходимо загружать рисунки в формате *.tga.
// Используемые текстуры должны быть сохр. с использованием 32 битного канала.
// Для конвертирования в  формат *.tga можно использовать Paint.net

const
  AppWidth  = 640;
  AppHeight = 480;

const
  Key_W = 119;
  Key_S = 115;
  Key_A = 97;
  Key_D = 100;
  Key_Z = 122;
  Key_X = 120;
  Key_ESC = 27;

var
  ScreenWidth, ScreenHeight : Integer;
  posX : Single;
  posY : Single;
  posZ : Single;

  Texture  : GLuint;
  Texture2 : GLuint;

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


procedure MYQUAD( Tex : integer);
begin
  Gl.glBindTexture(Gl.GL_TEXTURE_2D, Tex);
  GL.glBegin(GL.GL_QUADS);
  Gl.glTexCoord2f(0, 0);  gl.glVertex3f( -2.0,  2.0,  0.0); // 1
  Gl.glTexCoord2f(0, 1);  gl.glVertex3f( -2.0, -2.0,  0.0); // 2
  Gl.glTexCoord2f(1, 1);  gl.glVertex3f(  2.0, -2.0,  0.0); // 3
  Gl.glTexCoord2f(1, 0);  gl.glVertex3f(  2.0,  2.0,  0.0); // 4
  GL.glEnd();
end;

procedure MYQUAD2( Tex : integer);
begin
  Gl.glBindTexture(Gl.GL_TEXTURE_2D, Tex);
  GL.glBegin(GL.GL_QUADS);
  Gl.glTexCoord2f(0, 0);  gl.glVertex3f( -2.0,  2.0,  0.0); // 1
  Gl.glTexCoord2f(0, 2.5);  gl.glVertex3f( -2.0, -2.0,  0.0); // 2
  Gl.glTexCoord2f(2.5, 2.5);  gl.glVertex3f(  2.0, -2.0,  0.0); // 3
  Gl.glTexCoord2f(2.5, 0);  gl.glVertex3f(  2.0,  2.0,  0.0); // 4
  GL.glEnd();
end;


procedure MYTRIANGLE( Tex : integer);
begin
  Gl.glBindTexture(Gl.GL_TEXTURE_2D, Tex);
  GL.glBegin(GL.GL_TRIANGLES);
  Gl.glTexCoord2f(0.5, 1);  gl.glVertex3f(  0.0,  2.0,  0.0); // 1
  Gl.glTexCoord2f(0, 0);  gl.glVertex3f( -2.0, -2.0,  0.0); // 2
  Gl.glTexCoord2f(1, 0);  gl.glVertex3f(  2.0, -2.0,  0.0); // 3
  GL.glEnd();
end;

//****************************************************//
//********         Загрузка текстуры        **********//
//****************************************************//
function LoadTextere (filename : string) : Integer;
var
  // Создание пространства для хранения текстуры
  TextureImage: PSDL_Surface;
  texID : integer;
  nMaxAnisotropy : Integer;
begin
  nMaxAnisotropy := 16;

  TextureImage := IMG_Load(PChar(filename));

  if ( TextureImage <> Nil ) then begin
    // Создадим текстуру
    glEnable(GL_TEXTURE_2D);
    glGenTextures( 1, @texID );
    glBindTexture( GL_TEXTURE_2D, texID );

    glGetIntegerv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, @nMaxAnisotropy);
    if (nMaxAnisotropy > 0) then
      glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, nMaxAnisotropy);

      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
      //glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, TextureImage^.W,TextureImage^.H, 0, GL_BGR_EXT,GL_UNSIGNED_BYTE, TextureImage^.pixels);
      //glGenerateMipmap( GL_TEXTURE_2D );

      gluBuild2DMipmaps (GL_TEXTURE_2D, GL_RGBA , TextureImage^.W,TextureImage^.H, GL_BGRA_EXT, GL_UNSIGNED_BYTE, TextureImage^.pixels);
  end;

  // Освобождаем память от картинки
  if ( TextureImage <> nil ) then
    SDL_FreeSurface( TextureImage );

  Result := texID;
end;

//****************************************************//
//***  Инициализация ресурсов приложения и OpenGL  ***//
//****************************************************//
procedure InitScene;
begin
  glClearColor(0.0, 0.0, 0.0, 0.0);

  glEnable(GL_DEPTH_TEST);

  //glEnable( GL_TEXTURE_2D );

  glEnable( GL_ALPHA_TEST );
  glAlphaFunc( GL_GREATER, 0.0 );

  glEnable ( GL_BLEND );
  glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
 //glBlendEquation( GL_FUNC_ADD );
 // Метод в текущей версии FPC 3.0.4 падает в исключение
 // возможно в след версиях это исправят


 Texture2 := LoadTextere('data\tex1.tga');
 Texture  := LoadTextere('data\a2.tga');
 posZ := 10.0;
end;

//****************************************************//
//***   Процедура отрисовки                        ***//
//***   Данная процедура вызывается каждый кадр    ***//
//****************************************************//
procedure RenderScene; cdecl;
var
  i, j : Integer;
begin
  glLoadIdentity();
  gluLookAt( posX, posY, posZ,
             posX, posY, posZ - 3.0,
            0.0, 1.0, 0.0);

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  for i := -10 to 10 do
  for j := -10 to 10 do begin
    glPushMatrix();
      glTranslatef( 1.0 * i, -1.5, 1.0 * j );
      glColor3f( 0.1 * i, 0.3, 0.1 * j );
      glutSolidCube(0.5);
    glPopMatrix();
  end;

  glPushMatrix();
    glTranslatef( 0.0, -1.5, 0.0 );
    glColor3f( 0.9, 0.3, 0.7);
    glutSolidTeapot(1.0);
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
begin

 case key of
  Key_W  : posZ := posZ - 1.0;
  Key_S  : posZ := posZ + 1.0;
  Key_A  : posX := posX - 1.0;
  Key_D  : posX := posX + 1.0;
  Key_Z  : posY := posY + 1.0;
  Key_X  : posY := posY - 1.0;
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
