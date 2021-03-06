{
      ORM Brasil � um ORM simples e descomplicado para quem utiliza Delphi

                   Copyright (c) 2016, Isaque Pinheiro
                          All rights reserved.

                    GNU Lesser General Public License
                      Vers�o 3, 29 de junho de 2007

       Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
       A todos � permitido copiar e distribuir c�pias deste documento de
       licen�a, mas mud�-lo n�o � permitido.

       Esta vers�o da GNU Lesser General Public License incorpora
       os termos e condi��es da vers�o 3 da GNU General Public License
       Licen�a, complementado pelas permiss�es adicionais listadas no
       arquivo LICENSE na pasta principal.
}

{ @abstract(ORMBr Framework.)
  @created(20 Jul 2016)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @author(Skype : ispinheiro)

  ORM Brasil � um ORM simples e descomplicado para quem utiliza Delphi.
}

{.$DEFINE LOAD_DYNAMICALLY}
{.$DEFINE FML}

// Delphi TOKYO
{$IFDEF VER320}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
  {$DEFINE DELPHI18_UP}
  {$DEFINE DELPHI19_UP}
  {$DEFINE DELPHI20_UP}
  {$DEFINE DELPHI21_UP}
  {$DEFINE DELPHI22_UP}
  {$DEFINE DELPHI23_UP}
  {$DEFINE DELPHI24_UP}
  {$DEFINE DELPHI25_UP}
{$ENDIF}

// Delphi BERLIN
{$IFDEF VER310}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
  {$DEFINE DELPHI18_UP}
  {$DEFINE DELPHI19_UP}
  {$DEFINE DELPHI20_UP}
  {$DEFINE DELPHI21_UP}
  {$DEFINE DELPHI22_UP}
  {$DEFINE DELPHI23_UP}
  {$DEFINE DELPHI24_UP}
{$ENDIF}

// Delphi SEATLLE
{$IFDEF VER300}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
  {$DEFINE DELPHI18_UP}
  {$DEFINE DELPHI19_UP}
  {$DEFINE DELPHI20_UP}
  {$DEFINE DELPHI21_UP}
  {$DEFINE DELPHI22_UP}
  {$DEFINE DELPHI23_UP}
{$ENDIF}

// Delphi XE8
{$IFDEF VER290}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
  {$DEFINE DELPHI18_UP}
  {$DEFINE DELPHI19_UP}
  {$DEFINE DELPHI20_UP}
  {$DEFINE DELPHI21_UP}
  {$DEFINE DELPHI22_UP}
{$ENDIF}

// Delphi XE7
{$IFDEF VER280}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
  {$DEFINE DELPHI18_UP}
  {$DEFINE DELPHI19_UP}
  {$DEFINE DELPHI20_UP}
  {$DEFINE DELPHI21_UP}
{$ENDIF}

// Delphi XE6
{$IFDEF VER270}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
  {$DEFINE DELPHI18_UP}
  {$DEFINE DELPHI19_UP}
  {$DEFINE DELPHI20_UP}
{$ENDIF}

// Delphi XE5
{$IFDEF VER260}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
  {$DEFINE DELPHI18_UP}
  {$DEFINE DELPHI19_UP}
{$ENDIF}

// Delphi XE4
{$IFDEF VER250}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
  {$DEFINE DELPHI18_UP}
{$ENDIF}

// Delphi XE3
{$IFDEF VER240}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
{$ENDIF}

// Delphi XE2
{$IFDEF VER230}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
{$ENDIF}

// Delphi XE
{$IFDEF VER220}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
{$ENDIF}

//Delphi 2010
{$IFDEF VER210}
  {$DEFINE DELPHI14_UP}
{$ENDIF}

{$IFDEF DELPHI15_UP}
  {$DEFINE FORMATSETTINGS}
{$ENDIF}