unit validation_u;

interface
  function validateStr(sInput: string): boolean;
  function validateInt(sInput: string): boolean;
  function validateReal(sInput: string): boolean;
  function presence(sInput: string): boolean;
  function validatePassword(sPassword: string): boolean;
  function validateUsername(sUsername: string): boolean;

implementation
  uses
  Vcl.Dialogs;

// Validates that the string represents a valid integer (optional leading +/-)
function validateInt(sInput: string): boolean;
var
  iLoopStr: integer;
begin
  Result := True;
  if Length(sInput) = 0 then
  begin
    Result := False;
    Exit;
  end;

  for iLoopStr := 1 to Length(sInput) do
  begin
    if (iLoopStr = 1) and (sInput[iLoopStr] in ['+', '-']) then ;
    if not (sInput[iLoopStr] in ['0'..'9']) then
    begin
      Result := False;
    end;
  end;

  if (Length(sInput) = 1) and (sInput[1] in ['+', '-']) then
    Result := False;
end;

// Validates that the string contains only alphabetic characters and spaces
function validateStr(sInput: string): boolean;
var
  iLoopStr: integer;
begin
  Result := True;
  if Length(sInput) = 0 then
  begin
    Result := False;
    Exit;
  end;

  for iLoopStr := 1 to Length(sInput) do
  begin
    if not (sInput[iLoopStr] in ['A'..'Z', 'a'..'z', ' ']) then
    begin
      Result := False;
    end;
  end;
end;

function presence(sInput: string): boolean;
begin
  if length(sInput) = 0 then
    result := false
  else
    result := true;
end;

procedure ShowErrorMessage(const Msg: string);
begin
  ShowMessage('ERROR: ' + Msg);
end;

// Validates that the string represents a valid real number (e.g. -3.14, +0.5, 2.0)
function validateReal(sInput: string): boolean;
var
  iLoopStr  : integer;
  iDotCount : integer;
begin
  Result    := True;
  iDotCount := 0;
  if Length(sInput) = 0 then
  begin
    Result := False;
    Exit;
  end;

  for iLoopStr := 1 to Length(sInput) do
  begin
    if (iLoopStr = 1) and (sInput[iLoopStr] in ['+', '-']) then
    begin
      if sInput[iLoopStr] = '.' then
      begin
        Inc(iDotCount);
        if iDotCount > 1 then
        begin
          Result := False;
        end;
      end;

      if not (sInput[iLoopStr] in ['0'..'9']) then
      begin
        Result := False;
      end;
    end;
  end;

  if iDotCount = 1 then
  begin
    if (Length(sInput) <= 2) and
       ((sInput[1] in ['+', '-', '.']) or (sInput[Length(sInput)] = '.')) then
    begin
      iDotCount := 0; // reuse as digit counter
      for iLoopStr := 1 to Length(sInput) do
        if sInput[iLoopStr] in ['0'..'9'] then
          Inc(iDotCount);
      if iDotCount = 0 then
        Result := False;
    end;
  end;
  if (Length(sInput) = 1) and (sInput[1] in ['+', '-', '.']) then
    Result := False;
end;

function validatePassword(sPassword: string): Boolean;
var
  i: Integer;
  bHasUpper, bHasLower, bHasDigit, bHasSpecial: Boolean;
begin
  bHasUpper  := False;
  bHasLower  := False;
  bHasDigit  := False;
  bHasSpecial := False;

  // 8-4 Rule: minimum 8 characters + all 4 character types
  if Length(sPassword) < 8 then
  begin
    Result := False;
    Exit;
  end;

  for i := 1 to Length(sPassword) do
  begin
    if sPassword[i] in ['A'..'Z']      then bHasUpper   := True
    else if sPassword[i] in ['a'..'z'] then bHasLower   := True
    else if sPassword[i] in ['0'..'9'] then bHasDigit   := True
    else                                    bHasSpecial := True;
  end;

  Result := bHasUpper and bHasLower and bHasDigit and bHasSpecial;
end;

function ValidateUsername(sUsername: string): Boolean;
var
  i: Integer;
  bValid: Boolean;
begin
  bValid := True;

  // Must be at least 3 characters
  if Length(sUsername) < 3 then
    bValid := False;

  // Only letters, digits, and underscores allowed
  for i := 1 to Length(sUsername) do
  begin
    if not (sUsername[i] in ['a'..'z', 'A'..'Z', '0'..'9', '_']) then
    begin
      bValid := False;
    end;
  end;

  Result := bValid;
end;

end.
