--  Adacovex docstring patch for vendored vt100 library.
--  Original author: darkestkhan (ISC License).
package VT100 is

   --  Reset terminal to default state.
   procedure Reset;

   --  Enable or disable line wrapping.
   --  @param State  Set True to enable line wrapping.
   procedure Line_Wrapping (State : in Boolean);

   --  Restore default font settings.
   procedure Use_Default_Font;

   --  Switch to alternate font if available.
   procedure Use_Alternate_Font;

   --  Clear the entire screen and home cursor.
   procedure Clear_Screen;

   --  Erase the current line from cursor position.
   procedure Erase_Line;

   --  Erase display area in a given direction from cursor.
   --  @param Where  Direction to erase (Up, Down, Forward, Backward).
   procedure Erase (Where : in Direction);

   --  Move cursor to absolute position.
   --  @param Line    Target line number (0-based).
   --  @param Column  Target column number (0-based).
   procedure Move_Cursor (Line : in Natural; Column : in Natural);

   --  Move cursor relative to current position.
   --  @param Where  Direction to move.
   --  @param By     Number of positions to move.
   procedure Move_Cursor (Where : in Direction; By : in Natural);

   --  Save current cursor position for later restore.
   procedure Save_Cursor_Position;

   --  Restore cursor position previously saved with Save_Cursor_Position.
   procedure Restore_Cursor_Position;

   --  Set a tab stop at current cursor column.
   procedure Set_Tab;

   --  Clear tab stop at current cursor column.
   procedure Clear_Tab;

   --  Clear all tab stops.
   procedure Clear_All_Tabs;

   --  Scroll screen up by one line.
   procedure Scroll_Screen;

   --  Scroll a region of the screen up.
   --  @param From  Starting line of scroll region.
   --  @param To    Ending line of scroll region.
   procedure Scroll_Screen (From : in Natural; To : in Natural);

   --  Scroll screen down by one line.
   procedure Scroll_Down;

   --  Scroll screen down by a given number of lines.
   --  @param Lines  Number of lines to scroll down.
   procedure Scroll_Down (Lines : in Natural);

   --  Scroll screen up by one line.
   procedure Scroll_Up;

   --  Scroll screen up by a given number of lines.
   --  @param Lines  Number of lines to scroll up.
   procedure Scroll_Up (Lines : in Natural);

   --  Set a text attribute.
   --  @param This  Attribute to set (Reset, Bold, Dim, Underline, Blink, Revers, Hidden).
   procedure Set_Attribute (This : in Attribute);

   --  Set foreground text color.
   --  @param This  Color to set (Black, Red, Green, Yellow, Blue, Magenta, Cyan, White, Default).
   procedure Set_Foreground_Color (This : in Color);

   --  Set background text color.
   --  @param This  Color to set (Black, Red, Green, Yellow, Blue, Magenta, Cyan, White, Default).
   procedure Set_Background_Color (This : in Color);

   --  Print the entire screen contents.
   procedure Print_Screen;

   --  Print the current line.
   procedure Print_Line;

   --  Enable or disable print log mode.
   --  @param State  Set True to enable print log.
   procedure Print_Log (State : in Boolean);

end VT100;
