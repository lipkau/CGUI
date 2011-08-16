/*
Class: CStatusBarControl
The status bar. Can only be used once per window.
*/
Class CStatusBarControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		base.__New(Name, Options, Text, GUINum)
		this.Type := "StatusBar"
		this._.Parts := new this.CParts(this.GUINum, this.Name)
		this._.Insert("ControlStyles", {SizingGrip : 0x100})
		if(Text)
			this._.Parts._.Insert(1, new this.CParts.CPart(Text, 1, "", "", "", "", this.GUINum, this.Name))
		this._.Insert("Events", ["Click", "DoubleClick", "RightClick", "DoubleRightClick"])
	}
	__Get(Name, Params*)
	{
		if(Name = "Parts")
			Value := this._.Parts
		else if(Name = "Text")
			Value := this._.Parts[1].Text
		Loop % Params.MaxIndex()
				if(IsObject(Value)) ;Fix unlucky multi parameter __GET
					Value := Value[Params[A_Index]]
		if(Value != "")
			return Value
	}
	__Set(Name, Params*)
	{
		Value := Params[Params.MaxIndex()]
		Params.Remove(Params.MaxIndex())
		if(Name = "Text") ;Assign text -> assign text of first part
		{
			this._.Parts[1].Text := Value
			return true
		}
		if(Name = "Parts") ;Assign all parts at once
		{
			if(Params[1] >= 1 && Params[1] <= this._.Parts.MaxIndex()) ;Set a single part
			{
				if(IsObject(Value)) ;Set an object
				{
					Part := new this.CParts.CPart(Value.HasKey("Text") ? Value.Text : "", Params[1], Value.HasKey("Width") ? Value.Width : 50, Value.HasKey("Style") ? Value.Style : "", Value.HasKey("Icon") ? Value.Icon : "", Value.HasKey("IconNumber") ? Value.IconNumber : "", this.GUINum, this.Name)
					this._.Parts._.Remove(Params[1])
					this._.Parts._.Insert(Params[1], Part)
					this.RebuildStatusBar()
				}
				else ;Just set text directly
					this._Parts[Params[1]].Text := Value
				;~ PartNumber := Params[Params.MaxIndex()]
				;~ Params.Remove(Params.MaxIndex())
				;~ Part := this._.Parts[PartNumber]
				;~ Part := Value ;ASLDIHSVO)UGBOQWFH)=RFZS
				return Value
			}
			else
			{
				Data := Value
				if(!IsObject(Data))
				{
					Data := Object()
					Loop, Parse, Value, |
						Data.Insert({Text : A_LoopField})
				}
				this._.Insert("Parts", new this.CParts(this.GUINum, this.Name))
				Loop % Data.MaxIndex()
					this._.Parts._.Insert(new this.CParts.CPart(Data[A_Index].HasKey("Text") ? Data[A_Index].Text : "", A_Index, Data[A_Index].HasKey("Width") ? Data[A_Index].Width : 50, Data[A_Index].HasKey("Style") ? Data[A_Index].Style : "", Data[A_Index].HasKey("Icon") ? Data[A_Index].Icon : "", Data[A_Index].HasKey("IconNumber") ? Data[A_Index].IconNumber : "", this.GUINum, this.Name))
				this.RebuildStatusBar()
			}
			return Value
		}
	}
	/*
	Reconstructs the statusbar from the information stored in this.Parts
	*/
	RebuildStatusBar()
	{
		Widths := []
		for index, Part in this._.Parts
			if(index < this._.Parts._.MaxIndex()) ;Insert all but the last one
				Widths.Insert(Part.Width ? Part.Width : 50)
		
		Gui, % this.GUINum ":Default"
		SB_SetParts()
		SB_SetParts(Widths*)
		for index, Part in this._.Parts
		{
			SB_SetText(Part.Text, index, Part.Style)
			;~ if(Part.Icon)
				SB_SetIcon(Part.Icon, Part.IconNumber, index)
		}
	}
	
	Class CParts
	{
		__New(GUINum, Name)
		{
			this.Insert("_", [])
			this.GUINum := GUINum
			this.Name := Name
		}
		__Get(Name, Params*)
		{
			if Name is Integer
			{
				if(Name <= this._.MaxIndex())
				{
					if(Params.MaxIndex() >= 1)
						return this._[Name][Params*]
					else						
						return this._[Name]
				}
			}
		}
		MaxIndex()
		{
			return this._.MaxIndex()
		}
		_NewEnum()
		{
			global CEnumerator
			return new CEnumerator(this._)
		}
		__Set(Name, Params*)
		{
			global CGUI
			Value := Params[Params.MaxIndex()]
			Params.Remove(Params.MaxIndex())
			if Name is Integer
			{
				if(Name <= this._.MaxIndex())
				{
					if(Params.MaxIndex() >= 1) ;Set a property of CPart
					{
						Part := this._[Name]
						Part[Params*] := Value
					}
					;~ else
					;~ {
						
					;~ }
					return Value
				}
			}
		}
		Add(Text, PartNumber = "", Width = 50, Style = "", Icon = "", IconNumber = "")
		{
			global CGUI
			if(PartNumber)
				this._.Insert(PartNumber, new this.CPart(Text, PartNumber, Width, Style, Icon, IconNumber, this.GUINum, this.Name))
			else
				this._.Insert(new this.CPart(Text, this._.MaxIndex() + 1, Width, Style, Icon, IconNumber, this.GUINum, this.Name))
			Control := CGUI.GUIList[this.GUINum][this.Name]
			Control.RebuildStatusBar()
		}
		Remove(PartNumber)
		{
			global CGUI
			if PartNumber is Integer
			{
				this._.Remove(PartNumber)
				Control := CGUI.GUIList[this.GUINum][this.Name]
				Control.RebuildStatusBar()
			}
		}
		Class CPart
		{
			__New(Text, PartNumber, Width, Style, Icon, IconNumber, GUINum, Name)
			{
				this.Insert("_", {})
				this._.Text := Text
				this._.PartNumber := PartNumber
				this._.Width := Width
				this._.Style := Style
				this._.Icon := Icon
				this._.IconNumber := IconNumber
				this._.GUINum := GUINum
				this._.Name := Name
			}
			__Get(Name)
			{
				if(Name != "_" && this._.HasKey(Name))
					return this._[Name]
			}
			__Set(Name, Value)
			{
				global CGUI
				Control := CGUI.GUIList[this.GUINum][this.Name]
				if(Name = "Width")
				{
					this._[Name] := Value
					Control.RebuildStatusBar()
					return Value
				}
				else if(Name = "Text" || Name = "Style")
				{
					this._[Name] := Value
					Gui, % this.GUINum ":Default"
					SB_SetText(Name = "Text" ? Value : this._.Text, this._.PartNumber, Name = "Style" ? Value : this._.Style)
				}
				else if(Name = "Icon" || Name = "IconNumber")
				{
					this._[Name] := Value
					if(this._.Icon)
					{
						Gui, % this.GUINum ":Default"
						SB_SetIcon(this._.Icon, this._.IconNumber, this._.PartNumber)
					}
					return Value
				}
			}
		}
	}
	/*
	Event: Introduction
	To handle control events you need to create a function with this naming scheme in your window class: ControlName_EventName(params)
	The parameters depend on the event and there may not be params at all in some cases.
	Additionally it is required to create a label with this naming scheme: GUIName_ControlName
	GUIName is the name of the window class that extends CGUI. The label simply needs to call CGUI.HandleEvent(). 
	For better readability labels may be chained since they all execute the same code.
	
	Event: Click(PartIndex)
	Invoked when the user clicked on the control.
	
	Event: DoubleClick(PartIndex)
	Invoked when the user double-clicked on the control.
	
	Event: RightClick(PartIndex)
	Invoked when the user right-clicked on the control.
	
	Event: DoubleRightClick(PartIndex)
	Invoked when the user double-right-clicked on the control.
	*/
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		ErrLevel := ErrorLevel
		Mapping := {Normal : "_Click", DoubleClick : "_DoubleClick", Right : "_RightClick", R : "_DoubleRightClick"}
		func := this.Name Mapping[A_GuiEvent]
		if(IsFunc(CGUI.GUIList[this.GUINum][func]))
		{
			ErrorLevel := ErrLevel
			`(CGUI.GUIList[this.GUINum])[func](A_EventInfo)
		}
	}
}