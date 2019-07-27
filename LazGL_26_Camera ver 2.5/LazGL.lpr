program LazGL;

{$mode objfpc}{$H+}

uses
  gl, glu, glut, GLext, sdl, sdl_image ;
// sdl - многофункциональная библиотека, в данном примере будет
// использоваться для загрузки изображений

// Для нормальной работы приложения необходимо загружать рисунки в формате *.tga.
// Используемые текстуры должны быть сохр. с использованием 32 битного канала.
// Для конвертирования в  формат *.tga можно использовать Paint.net


// Функции для работы с курсором
  function SetCursorPos(x, y: integer): boolean;  stdcall; external 'user32' name 'SetCursorPos';
  function GetCursorPos(var pt: TPoint): boolean; stdcall; external 'user32' name 'GetCursorPos';
  function ShowCursor(bShow: boolean): integer;    stdcall; external 'user32' name 'ShowCursor';


//****************************************************//
//********         Описание вектора         **********//
//****************************************************//
type
  Vector3D = record
    X, Y, Z:  real;
end;


  //****************************************************//
  //********            Класс камеры          **********//
  //****************************************************//
  type
    Camera = class
    private
      mPos: Vector3D;    // Вектор позиции камеры
      mView: Vector3D;   // Направление, куда смотрит камера
      mUp: Vector3D;     // Вектор направления вверх
      mStrafe: Vector3D;  // Вектор для стрейфа (движения влево и вправо) камеры

    SCREEN_WIDTH, SCREEN_HEIGHT: integer;  // размеры окна
    PosWinX, PosWinY: integer;    // положение окна на мониторе
    middleX, middleY: integer;    // текущее положение курсора
    currentRotX, lastRotX: real;  // текущий и последний угол вращения
    angleY, angleZ: real;

    mousePos: TPoint;
  private
      //--------------------------------------------------------------
      // Перпендикулярный вектор от трех переданных векторов
      //--------------------------------------------------------------
       function Cross(vVector1, vVector2: Vector3D): Vector3D;

      //--------------------------------------------------------------
      // Возвращает величину вектора
      //--------------------------------------------------------------
      function Magnitude(vNormal: Vector3D): real;

      //--------------------------------------------------------------
      // Возвращает нормализированный вектор
      //--------------------------------------------------------------
      function Normalize(vVector: Vector3D): Vector3D;

      //--------------------------------------------------------------
    public

      //--------------------------------------------------------------
      //  Конструктор
      //--------------------------------------------------------------
      constructor Create(WIDTH, HEIGHT, posX, posY: integer);

      //--------------------------------------------------------------
      // Установить позицию камеры
      //--------------------------------------------------------------
      procedure Position_Camera(pos_x, pos_y, pos_z, view_x, view_y, view_z,
                                                     up_x, up_y, up_z : real);

      //--------------------------------------------------------------
      // Вращение камеры вокруг своей оси (от первого лица)
      //--------------------------------------------------------------
      procedure Rotate_View(speed: real);
      procedure Rotate_View(angle, x, y, z: real);

      //--------------------------------------------------------------
      // Перемещение камеры (вперед и назад)
      //--------------------------------------------------------------
      procedure Move_Camera(speed: real);

      //--------------------------------------------------------------
      // Перемещение камеры (влево и вправо)
      //--------------------------------------------------------------
      procedure Strafe(speed: real);

      //--------------------------------------------------------------
      // Перемещение вверх и вниз
      //--------------------------------------------------------------
      procedure upDown(speed: real);

      //--------------------------------------------------------------
      // Вращение вверх и вниз
      //--------------------------------------------------------------
      procedure upDownAngle(speed: real);

       //--------------------------------------------------------------
      // Установка камеры
      //--------------------------------------------------------------
      procedure Look();

      //--------------------------------------------------------------
      // Обновление
      //--------------------------------------------------------------
      procedure update();


      //--------------------------------------------------------------
      // Добавим ф-ю управления взглядом с пом. мышки
      //--------------------------------------------------------------
       procedure SetViewByMouse();

      //--------------------------------------------------------------
      // Возвращает позицию камеры по Х
      //--------------------------------------------------------------
      function getPosX: real;

      //--------------------------------------------------------------
      // Возвращает позицию камеры по Y
      //--------------------------------------------------------------
      function getPosY() : real;

      //--------------------------------------------------------------
      // Возвращает позицию камеры по Z
      //--------------------------------------------------------------
      function getPosZ() : real;

      //--------------------------------------------------------------
      // Возвращает позицию взгляда по Х
      //--------------------------------------------------------------
      function getViewX() : real;

      //--------------------------------------------------------------
      // Возвращает позицию взгляда по Y
      //--------------------------------------------------------------
      function getViewY() : real;

      //--------------------------------------------------------------
      // Возвращает позицию взгляда по Z
      //--------------------------------------------------------------
      function getViewZ() : real;

  end; //END CLASS
  //----------------------------------------------

      //--------------------------------------------------------------
      // Перпендикулярный вектор от трех переданных векторов
      //--------------------------------------------------------------
      function Camera.Cross(vVector1, vVector2: Vector3D): Vector3D;
    var
      vNormal: Vector3D;
    begin
      // Если у нас есть 2 вектора (вектор взгляда и вертикальный вектор),
      // У нас есть плоскость, от которой мы можем вычислить угол в 90 градусов.
      // Рассчет cross'a прост, но его сложно запомнить с первого раза.
      // Значение X для вектора = (V1.y * V2.z) - (V1.z * V2.y)
      vNormal.x := ((vVector1.y * vVector2.z) - (vVector1.z * vVector2.y));
      vNormal.y := ((vVector1.z * vVector2.x) - (vVector1.x * vVector2.z));
      vNormal.z := ((vVector1.x * vVector2.y) - (vVector1.y * vVector2.x));

      result := vNormal;
    end;

    //--------------------------------------------------------------
    // Возвращает величину вектора
    //--------------------------------------------------------------
    function Camera.Magnitude(vNormal: Vector3D): real;
    begin
      // Даёт величину нормали, т.е. длину вектора.
      // Мы используем эту информацию для нормализации вектора.
      result := Sqrt((vNormal.x * vNormal.x) +
               (vNormal.y * vNormal.y) + (vNormal.z * vNormal.z));
    end;

      //--------------------------------------------------------------
      // Возвращает нормализированный вектор
      //--------------------------------------------------------------
      function Camera.Normalize(vVector: Vector3D): Vector3D;
      var
        magnit: real;
      begin
        // Вектор нормализирован - значит, его длинна равна 1. Например,
        // вектор (2, 0, 0) после нормализации будет (1, 0, 0).

        // Вычислим величину нормали
        magnit := Magnitude(vVector);

        // Теперь у нас есть величина, и мы можем разделить наш вектор на его величину.
        // Это сделает длинну вектора равной единице, так с ним будет легче работать.
        vVector.x := vVector.x / magnit;
        vVector.y := vVector.y / magnit;
        vVector.z := vVector.z / magnit;

        result := vVector;
      end;

    //--------------------------------------------------------------
    //  Конструктор
    //--------------------------------------------------------------
    constructor Camera.Create(WIDTH, HEIGHT, posX, posY: integer);
    begin
      SCREEN_HEIGHT := HEIGHT;
      SCREEN_WIDTH := WIDTH;
      currentRotX := 0.0;
      lastRotX := 0.0;
      PosWinX := posX;
      PosWinY := posY;

      mousePos := TPoint.Create(PosWinX + (SCREEN_WIDTH div 2), PosWinY + (SCREEN_HEIGHT div 2));
    end;


      //--------------------------------------------------------------
      // Установить позицию камеры
      //--------------------------------------------------------------
      procedure Camera.Position_Camera(pos_x, pos_y, pos_z, view_x, view_y, view_z,
                                                     up_x, up_y, up_z : real);
      begin
        // Позиция камеры
        mPos.x := pos_x;
        mPos.y := pos_y;
        mPos.z := pos_z;

        // Куда смотрит, т.е. взгляд
        mView.x := view_x;
        mView.y := view_y;
        mView.z := view_z;

        // Вертикальный вектор камеры
        mUp.x := up_x;
        mUp.y := up_y;
        mUp.z := up_z;
      end;

      //--------------------------------------------------------------
      // Вращение камеры вокруг своей оси (от первого лица)
      //--------------------------------------------------------------
      procedure Camera.Rotate_View(speed: real);
      var
        vVector: Vector3D;
      begin
        // Полчим вектор взгляда
        vVector.x := mView.x - mPos.x;
        vVector.y := mView.y - mPos.y;
        vVector.z := mView.z - mPos.z;

        mView.z := (mPos.z + Sin(speed) * vVector.x + Cos(speed) * vVector.z);
        mView.x := (mPos.x + Cos(speed) * vVector.x - Sin(speed) * vVector.z);
      end;

      //--------------------------------------------------------------
    // Вращение камеры вокруг своей оси (от первого лица)
    //--------------------------------------------------------------
    procedure Camera.Rotate_View(angle, x, y, z: real);
    var
      vView, vNewView: Vector3D;
      cosTheta, sinTheta: real;
    begin
      // Получим наш вектор взгляда (направление, куда мы смотрим)
      vView.x := mView.x - mPos.x;	// направление по X
      vView.y := mView.y - mPos.y;	// направление по Y
      vView.z := mView.z - mPos.z;	// направление по Z

 	    // Рассчитаем 1 раз синус и косинус переданного угла
      cosTheta := Cos(angle);
      sinTheta := Sin(angle);

 	    // Найдем новую позицию X для вращаемой точки
      vNewView.x := (cosTheta + (1 - cosTheta) * x * x) * vView.x;
      vNewView.x += ((1 - cosTheta) * x * y - z * sinTheta)	* vView.y;
      vNewView.x += ((1 - cosTheta) * x * z + y * sinTheta)	* vView.z;

 	    // Найдем позицию Y
      vNewView.y := ((1 - cosTheta) * x * y + z * sinTheta)	* vView.x;
      vNewView.y += (cosTheta + (1 - cosTheta) * y * y)	* vView.y;
      vNewView.y += ((1 - cosTheta) * y * z - x * sinTheta)	* vView.z;

 	    // И позицию Z
      vNewView.z := ((1 - cosTheta) * x * z - y * sinTheta)	* vView.x;
      vNewView.z += ((1 - cosTheta) * y * z + x * sinTheta)	* vView.y;
      vNewView.z += (cosTheta + (1 - cosTheta) * z * z)	* vView.z;

 	    // Установливаем новый взгляд камеры
      mView.x := mPos.x + vNewView.x;
      mView.y := mPos.y + vNewView.y;
      mView.z := mPos.z + vNewView.z;
    end;



      //--------------------------------------------------------------
      // Перемещение камеры (вперед и назад)
      //--------------------------------------------------------------
      procedure Camera.Move_Camera(speed: real);
      var
        vVector:  Vector3D;
      begin
        // Получаем вектор взгляда
        vVector.x := mView.x - mPos.x;
        vVector.y := mView.y - mPos.y;
        vVector.z := mView.z - mPos.z;

        vVector.y := 0.0;  // Это запрещает камере подниматься вверх
        vVector := Normalize(vVector);

        mPos.x += vVector.x * speed;
        mPos.z += vVector.z * speed;
        mView.x += vVector.x * speed;
        mView.z += vVector.z * speed;
      end;

      //--------------------------------------------------------------
      // Перемещение камеры (влево и вправо)
      //--------------------------------------------------------------
      procedure Camera.Strafe(speed: real);
      begin
        // добавим вектор стрейфа к позиции
        mPos.x += mStrafe.x * speed;
        mPos.z += mStrafe.z * speed;

        // Добавим теперь к взгляду
        mView.x += mStrafe.x * speed;
        mView.z += mStrafe.z * speed;
      end;

      //--------------------------------------------------------------
      // Перемещение вверх и вниз
      //--------------------------------------------------------------
      procedure Camera.upDown(speed: real);
      begin
        mPos.y +=  speed;
        mView.y +=  speed;
      end;

      //--------------------------------------------------------------
      // Вращение вверх и вниз
      //--------------------------------------------------------------
      procedure Camera.upDownAngle(speed: real);
      var
        vVector: Vector3D;
      begin
        // Полчим вектор взгляда
        vVector.x := mView.x - mPos.x;
        vVector.y := mView.y - mPos.y;
        vVector.z := mView.z - mPos.z;
        mView.y += speed;
      end;

      //--------------------------------------------------------------
    // Добавим ф-ю управления взглядом с пом. мышки
    //--------------------------------------------------------------
    procedure Camera.SetViewByMouse();
    var
      vAxis: Vector3D;
      vVecTemp: Vector3D;

    begin
      middleX := PosWinX + SCREEN_WIDTH div 2;	// Вычисляем половину ширины
      middleY := PosWinY + SCREEN_HEIGHT div 2;	// И половину высоты экрана

      angleY := 0.0;	// Направление взгляда вверх/вниз
      angleZ := 0.0;	// Значение, необходимое для вращения влево-вправо (по оси Y)


      ShowCursor(false);

 	    // Получаем текущие коорд. мыши
      GetCursorPos(mousePos);

 	    // Если курсор остался в том же положении, мы не вращаем камеру
      if not ((mousePos.x = middleX) and (mousePos.y = middleY)) then begin

   	    // Теперь, получив координаты курсора, возвращаем его обратно в середину.
        SetCursorPos(middleX, middleY);

   	    // Теперь нам нужно направление (или вектор), куда сдвинулся курсор.
   	    // Его рассчет - простое вычитание. Просто возьмите среднюю точку и вычтите из неё
   	    // новую позицию мыши: VECTOR = P1 - P2; где P1 - средняя точка (400,300 при 800х600).
   	    // После получения дельты X и Y (или направления), я делю значение
   	    // на 1000, иначе камера будет жутко быстрой.

        angleY := (middleX - mousePos.x) / 1000.0;
        angleZ := (middleY - mousePos.y) / 1000.0;
        lastRotX := currentRotX;		// Сохраняем последний угол вращения

   	    // Если текущее вращение больше 1 градуса, обрежем его, чтобы не вращать слишком быстро
        if (currentRotX > 1.0) then
        begin
          currentRotX := 1.0;

    		    // врощаем на оставшийся угол
          if(not (lastRotX = 1.0)) then
          begin
     			    // Чтобы найти ось, вокруг которой вращаться вверх и вниз, нужно
     			    // найти вектор, перпендикулярный вектору взгляда камеры и
     			    // вертикальному вектору.
     			    // Это и будет наша ось. И прежде чем использовать эту ось,
     			    // неплохо бы нормализовать её.


            vVecTemp.x := mView.x - mPos.x;
            vVecTemp.y := mView.y - mPos.y;
            vVecTemp.z := mView.z - mPos.z;

            vAxis := Cross(vVecTemp, mUp);
            vAxis := Normalize(vAxis);

     			    // Вращаем камеру вокруг нашей оси на заданный угол
            Rotate_View(1.0 - lastRotX, vAxis.x, vAxis.y, vAxis.z);
          end;
        end

   	    // Если угол меньше -1.0f, убедимся, что вращение не продолжится
        else if(currentRotX < -1.0) then
        begin
          currentRotX := -1.0;
          if not (lastRotX = -1.0) then
          begin

            vVecTemp.x := mView.x - mPos.x;
            vVecTemp.y := mView.y - mPos.y;
            vVecTemp.z := mView.z - mPos.z;
            vAxis := Cross(vVecTemp, mUp);
            vAxis := Normalize(vAxis);
            Rotate_View(-1.0 - lastRotX, vAxis.x, vAxis.y, vAxis.z);
          end;
        end

   	    // Если укладываемся в пределы 1.0f -1.0f - просто вращаем
         else
        begin

          vVecTemp.x := mView.x - mPos.x;
          vVecTemp.y := mView.y - mPos.y;
          vVecTemp.z := mView.z - mPos.z;
          vAxis := Cross(vVecTemp, mUp);
          vAxis := Normalize(vAxis);
          Rotate_View(angleZ, vAxis.x, vAxis.y, vAxis.z);
        end;

   	    // Всегда вращаем камеру вокруг Y-оси
        Rotate_View(angleY, 0, 1, 0);
      end;
    end;



       //--------------------------------------------------------------
      // Установка камеры
      //--------------------------------------------------------------
      procedure Camera.Look();
      begin
        Glu.gluLookAt(mPos.x, mPos.y, mPos.z, // Ранее упомянутая команда
                      mView.x, mView.y, mView.z,
                      mUp.x, mUp.y, mUp.z);
      end;

      //--------------------------------------------------------------
      // Обновление
      //--------------------------------------------------------------
      procedure Camera.update();
      var
        vCross: Vector3D;
        vVecTemp: Vector3D;
      begin

        vVecTemp.x := mView.x - mPos.x;
        vVecTemp.y := mView.y - mPos.y;
        vVecTemp.z := mView.z - mPos.z;

        vCross := Cross(vVecTemp, mUp);

        // Нормализуем вектор стрейфа
        mStrafe := Normalize(vCross);

        // Посмотрим, двигалась ли мыша
        SetViewByMouse();
      end;

   //--------------------------------------------------------------
      // Возвращает позицию камеры по Х
      //--------------------------------------------------------------
      function Camera.getPosX: real;
      begin
        Result :=  mPos.x;
      end;

      //--------------------------------------------------------------
      // Возвращает позицию камеры по Y
      //--------------------------------------------------------------
      function Camera.getPosY() : real;
      begin
        Result :=  mPos.y;
      end;

      //--------------------------------------------------------------
      // Возвращает позицию камеры по Z
      //--------------------------------------------------------------
      function Camera.getPosZ() : real;
      begin
        Result :=  mPos.z;
      end;

   //--------------------------------------------------------------
      // Возвращает позицию взгляда по Х
      //--------------------------------------------------------------
      function Camera.getViewX() : real;
      begin
        Result :=  mView.x;
      end;

      //--------------------------------------------------------------
      // Возвращает позицию взгляда по Y
      //--------------------------------------------------------------
      function Camera.getViewY() : real;
      begin
        Result :=  mView.y;
      end;

      //--------------------------------------------------------------
      // Возвращает позицию взгляда по Z
      //--------------------------------------------------------------
      function Camera.getViewZ() : real;
      begin
        Result :=  mView.z;
      end;

//------------------------------------------------------------------------




const
  AppWidth  = 640;
  AppHeight = 480;

const
  Key_W = 119;
  Key_S = 115;
  Key_A = 97;
  Key_D = 100;
  Key_Q = 113;
  Key_E = 101;
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

  Cam: Camera;

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
    //glEnable(GL_TEXTURE_2D);
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

  {
  glEnable( GL_TEXTURE_2D );

  glEnable( GL_ALPHA_TEST );
  glAlphaFunc( GL_GREATER, 0.0 );

  glEnable ( GL_BLEND );
  glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  }
 //glBlendEquation( GL_FUNC_ADD );
 // Метод в текущей версии FPC 3.0.4 падает в исключение
 // возможно в след версиях это исправят


 Texture2 := LoadTextere('data\tex1.tga');
 Texture  := LoadTextere('data\a2.tga');

 // Создание камеры и задание первоначальных значений
 // Создание камеры и задание первоначальных значений
 Cam := Camera.Create(AppWidth, AppHeight, 300, 200);
 Cam.Position_Camera(0.0, 0.0, 3.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
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
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  Cam.Look();

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

  Cam.update();

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
  Key_W  : Cam.Move_Camera( 1.0);
  Key_S  : Cam.Move_Camera(-1.0);
  Key_A  : Cam.Strafe(-1.0);
  Key_D  : Cam.Strafe( 1.0);
  Key_Q  : Cam.Rotate_View(-0.05);
  Key_E  : Cam.Rotate_View( 0.05);
  Key_Z  : Cam.upDownAngle (-0.05);
  Key_X  : Cam.upDownAngle ( 0.05);
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
