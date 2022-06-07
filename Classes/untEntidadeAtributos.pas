unit untEntidadeAtributos;

interface

type
  NodePrincipal = class(TCustomAttribute)
    private
      FName : string;
    public
      constructor Create(aName: string);
      property name : string read FName write FName;
  end;

type
  NodePai = class(TCustomAttribute)

    private
      FName : string;

    public
      constructor Create(aName: string);
      property name : string read FName write FName;
  end;

type
  NodeFilho = class(TCustomAttribute)

    private
      FName : string;

    public
      constructor Create(aName: string);
      property name : string read FName write FName;
  end;

  type
    FieldName = class(TCustomAttribute)

    private
      FName : string;

    public
      constructor Create(aName: string);
      property name : string read FName write FName;
  end;

implementation

{ NodePAi }

constructor NodePai.Create(aName: string);
begin
  FName := aName;
end;

{ FieldName }

constructor FieldName.Create(aName: string);
begin
  FName := aName;
end;

{ NodePrincipal }

constructor NodePrincipal.Create(aName: string);
begin
  FName := aName;
end;

{ NodeFilho }

constructor NodeFilho.Create(aName: string);
begin
  FName := aName;
end;

end.
