with Ada.Characters.Conversions;
with Ada.Command_Line; use Ada.Command_Line;
with Ada.Integer_Text_IO;
with Ada.Streams; use Ada.Streams;
with Ada.Strings.UTF_Encoding.Wide_Wide_Strings;
with Ada.Strings.UTF_Encoding.Strings;
with Ada.Text_IO;
with Ada.Wide_Wide_Text_IO;
with GNAT.IO;

procedure Utf8test is

   package Conv renames Ada.Characters.Conversions;
   package Enc8 renames Ada.Strings.UTF_Encoding.Strings;
   package Enc32 renames Ada.Strings.UTF_Encoding.Wide_Wide_Strings;
   package GIO renames GNAT.IO;
   package TIO renames Ada.Text_IO;
   package WIO renames Ada.Wide_Wide_Text_IO;

   function Byte_Image (B : Stream_Element) return String is
      use Ada.Integer_Text_IO;
      Img : String (1 .. 6);
   begin
      Put (Img, Integer (B), Base => 16);
      return Img (4 .. 5);
   end Byte_Image;

   type Charsets is (Latin1, Utf8);

   procedure Print_Bytes (S       : String; -- Either latin1 or utf8
                          WWS     : Wide_Wide_String; -- Always proper utf32
                          Label   : String;
                          Charset : Charsets) -- Say what S is
   is
      Bytes : Stream_Element_Array (1 .. S'Length);
      for Bytes'Address use S'Address;

      use Ada.Text_IO;
   begin
      Put (Label & " is" & S'Length'Image & " bytes: ");
      for B of Bytes loop
         Put (Byte_Image (B) & ":");
      end loop;
      New_Line;
      GIO.Put_Line (Label & "  GIO image is: " & S);
      if Charset = Latin1 then
         TIO.Put_Line (Label & "  TIO image is: " & S);
         --  It breaks the terminal sometimes for utf8 sequences
      end if;
      WIO.Put_Line (Conv.To_Wide_Wide_String (Label)
                    & " WWIO image is: " & WWS);
      case Charset is
         when Latin1 =>
            WIO.Put_Line (Conv.To_Wide_Wide_String (Label
                          & " latin1->utf32 image is: " & S));
         when Utf8 =>
            WIO.Put_Line (Enc32.Decode (Label
                          & " utf8->utf32 image is: " & S));
      end case;
      New_Line;
   end Print_Bytes;

   Ascii : constant String := "aeiou";
   Lat1  : constant String := "áéíóú"; --  This is not unicode but Latin1, even
                                       --  if the source file is in utf8!
   Utf8_From_Latin1 : constant String := Enc8.Encode (String'("áéíóú"));
   Utf8_From_Utf32  : constant String := Enc32.Encode (Wide_Wide_String'("€"));

begin
   Print_Bytes (Ascii, Conv.To_Wide_Wide_String (Ascii),   "ascii", Latin1);
   Print_Bytes (Lat1, Conv.To_Wide_Wide_String (Lat1), "latin1", Latin1);
   Print_Bytes (Utf8_From_Latin1, Enc32.Decode (Utf8_From_Latin1),
                "lat1->utf8", Utf8);
   Print_Bytes (Utf8_From_Utf32, Enc32.Decode (Utf8_From_Utf32),
                "utf32->utf8", Utf8);

   for I in 1 .. Argument_Count loop
      Print_Bytes (Argument (I),
                   Enc32.Decode (Argument (I)),
                   --  Presuming Ada.Arguments strings are the raw input
                   "Arg" & I'Image,
                   Utf8);
   end loop;
end Utf8test;
