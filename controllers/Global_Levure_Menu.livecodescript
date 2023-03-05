script "Global | Levure | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Levure | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

/**
Summary: Creates a new DataView after prompting the user for some options.

Parameters:
pTargetCard: A reference to the card to create the DataView on. Default is the current card of the topStack.
pBehavior: Pass in a reference to a behavior that extends the behavior of the DataView. For example, the behavior for a DataView Tree or DataView array controller. Optional.
pRowStyleTemplateGroupsA: An array keyed by style names. See `dvIdeCreateRowTemplates`.

Description:

Returns:
it: The long id of the new control. Empty if an error occurs.
*/

command levure_CreateDataViewDialog pTargetCard, pBehavior, pRowStyleTemplateGroupsA
   local tError, tPropsA, tBehavior, tControl
   
   if pBehavior is empty then
      put the long id of stack "DataView Array Controller Behavior" into pBehavior
   end if 
   if pTargetCard is empty then
      put the long id of the current card of the topStack into pTargetCard
   end if
   
   modal stack "dvIdeCreateDataViewDialog"
   if the dialogData is "cancel" then
      put "cancel" into tError
   end if
   
   if tError is empty then
      put the dialogData into tPropsA
      
      if tPropsA["behavior name"] is not empty then
         local tParentBehavior
         
         put pBehavior into tParentBehavior
         if tParentBehavior is empty then
            put the long id of stack "DataView Behavior" into tParentBehavior
         end if
         
         dvIdeCreateBehaviorStack tPropsA["behavior name"], tPropsA["behavior filename"], \
               the long id of the owner of pTargetCard, tParentBehavior
         put the result into tError
         
         if tError is empty then
            put the long id of stack tPropsA["behavior name"] into pBehavior
         end if
      end if
   end if
   
   if tError is empty then
      dvIdeCreateDataViewControl tPropsA["name"], pTargetCard, pBehavior
      put it into tControl
      
      if tPropsA["create row template"] then
         local tStyle
         
         dvIdeCreateRowTemplates tControl, tPropsA["row template styles"], pRowStyleTemplateGroupsA
         put the result into tError
      end if
   end if
   
   if tError is empty then
      return tControl for value
   else
      if tError is not "cancel" then
         answer error tError
      end if
      return tError for error
   end if
end levure_CreateDataViewDialog


--> Menu | Props
-
on menu_Init tObject
   put tObject into LocalArray ["tObject"]
   put the display_View of tObject into displayView
   put displayView into LocalArray ["displayView"]
   put stacks_ListOpen() into LocalArray ["oStackNames"]
end menu_Init

getprop menu_Target [tObject]
   -- _SelectedDataView()
   put the dv_LinkedDataView of tObject into dView
   put dView into LocalArray ["dView"]
   --
   if exists (dView) is true then
      put the dv_RowStyleNames of dView into rowStyleNames
      sort rowStyleNames
   else
      put empty into rowStyleNames
   end if
   put rowStyleNames into LocalArray ["rowStyleNames"]
   --
   put dView into LocalArray ["dView"]
   return dView
end menu_Target

private function _SelectedRowView
   ---get the selectedObject
   -- if it is not empty then return the dvRowControl of it
   put _GetLinkedDataView() into dView
   if exists (dView) is false then return empty
   
   put the dvClickRow of dView into rowNum
   put the dvControlOfRow [rowNum] of dView into rowView
   return rowView
end _SelectedRowView

private function _SelectedDataView
   get the selectedObject
   if it is empty then return empty
   put the dvControl of it into dView
   return dView
end _SelectedDataView

private function _HelperTargetStackName
   put LocalArray ["helperTargetStackName"] into helperTargetStackName
   if helperTargetStackName is empty then return line 1 of LocalArray ["oStackNames"]
   --
   return helperTargetStackName
end _HelperTargetStackName

private function stacks_ListOpen
   put the openstacks into oStackNames
   filter oStackNames without "Display *"
   filter oStackNames without "rev*"
   filter oStackNames without "com.*"
   return oStackNames
end stacks_ListOpen

getprop disabled_RowBehavior [mTarget]
   return false
   
   if _SelectedRowView() is empty then
      return "delete"
   else
      return false
   end if
end disabled_RowBehavior

getprop replaceRowTemplate_Params [dView]
   return LocalArray ["rowStyleNames"]
end replaceRowTemplate_Params

getprop rowTemplateScript_Params [dView]
   return LocalArray ["rowStyleNames"]
end rowTemplateScript_Params

getprop levureHelper_Param [displayView]
   return _HelperTargetStackName()
end levureHelper_Param

getprop levureHelper_Params [displayView]
   put LocalArray ["oStackNames"] into oStackNames
   return oStackNames
end levureHelper_Params

getprop checked_StackIsKnown [dView]
   put _HelperTargetStackName() into helperTargetStackName
   put the stack_IsKnown of stack helperTargetStackName into isKnown
   return isKnown
end checked_StackIsKnown

getprop disabled_StackIsKnown [dView]
   return LocalArray ["helperTargetStackName"] is empty
end disabled_StackIsKnown

getprop disabled_DataViewData [dView]
   put _GetLinkedDataView() into dView
   return exists (dView) is false
end disabled_DataViewData

getprop disabled_RowStyleTemplates [dView]
   -- put _GetLinkedDataView() into dView
   return exists (dView) is false
end disabled_RowStyleTemplates

getprop disabled_RefreshSelected [dView]
   -- put _GetLinkedDataView() into dView
   return exists (dView) is false
end disabled_RefreshSelected

getprop disabled_Deselect [dView]
   put _SelectedDataView() into dView
   if exists (dView) then
      return false
   else
      return "delete"
   end if
end disabled_Deselect

getprop checked_SetLinkedDataView [dView]
   -- put _GetLinkedDataView() into dView
   return exists (dView)
end checked_SetLinkedDataView

getprop checked_CanDrag [dView]
   put the dv_CanDrag of dView into canDrag
   return canDrag
end checked_CanDrag


--> Global | Levure | Menu
-
-- see also "Global | DataView | Menu

on menu_CanDrag dView
   put the dv_CanDrag of dView is false into cantDrag
   set the dv_CanDrag of dView to cantDrag
end menu_CanDrag

on submenu_ImportData
   return "Global | Wiki | Data | Menu"
end submenu_ImportData

on submenu_DynamicMenu
   put LocalArray ["dView"] into dView
   if exists (dView) is false then return empty
   --
   put the dvClickRow of dView into rowNum
   put the dvRowData [rowNum] of dView into rowData
   put rowData ["@style"] into itemStyle
   put merge ("Global | Wiki | [[itemStyle]] | Menu") into gMenuTitle
   switch itemStyle
      case "Text"
         return "Global | Wiki | Markdown | Menu"
      case "video"
         return "Global | Glitch | Menu"
      default
         -- important to include this as returning an array or other bad data mucks up recursion checking
         return gMenuTitle
   end switch
end submenu_DynamicMenu

on _
end _

on menu_RowTemplateScript dView, rowStyleName
   put the dv_RowTemplate [rowStyleName] of dView into rowTemplate
   put the behavior of rowTemplate into bObject
   edit the script of bObject
end menu_RowTemplateScript

on menu_ReplaceRowTemplate dView, rowStyleName
   put lcw_Ask("View of module to replace the row teplate:", "View|Wiki|Markdown") into viewName
   -- put module_GetTemplateObject (viewName) into templateObject
   put view_GetTemplateObject (viewName) into templateObject
   --
   set the dv_RowTemplate [rowStyleName] of dView to templateObject
end menu_ReplaceRowTemplate

on menu_RowStyleTemplates dView
   -- put the viewProp ["row style templates"] of dView into styleArray
   put the dv_RowStyleArray of dView into styleArray
   put "DataView" && kwote (the short name of dView) into sTitle
   --
   display_Data styleArray, "Row Style Array", sTitle
end menu_RowStyleTemplates

on _
end _

on menu_RowData dView
   put the dvClickRow of dView into rowNum
   put the dvRowData [rowNum] of dView into rowData
   --
   display_Data rowData, rowNum, "Row Data"
end menu_RowData

on menu_RowBehavior dView
   put _SelectedRowView() into rowView
   put the behavior of rowView into bObject
   if exists (bObject) is false then
      put bObject
      lcw_AnswerWarning "Cannot locate behavior!"
   end if
   --
   edit the script of bObject
end menu_RowBehavior

on _
end _

getprop disabled_DisplayRowModule [dView]
   put _ClickedLinkedModule (dView) into rowModule
   if exists (rowModule) then
      return false
   else
      return "delete"
   end if
end disabled_DisplayRowModule

getprop disabled_CreateRowModule [dView]
   put _ClickedLinkedModule (dView) into rowModule
   if exists (rowModule) then
      return "delete"
   else
      return false
   end if
end disabled_CreateRowModule

private function _ClickedLinkedModuleName dView
   put _ClickedRowData (dView) into rowData
   --
   put rowData ["@style"] into itemStyle
   put "View|Wiki|" & text_InitialCaps(itemStyle) into moduleName
   --
   return moduleName
end _ClickedLinkedModuleName

private function _ClickedLinkedModule dView
   put _ClickedLinkedModuleName (dView) into moduleName
   put view_GetTemplateObject (moduleName) into rowModule
   --  put module_GetTemplateObject (moduleName) into rowModule
   return rowModule
end _ClickedLinkedModule

private function _ClickedRowData dView
   --  put the behavior of _SelectedRowView() into bObject
   put the dvClickRow of dView into rowNum
   put the dvRowData [rowNum] of dView into rowData
   return rowData
end _ClickedRowData

on menu_DisplayRowModule dView
   put _ClickedLinkedModuleName (dView) into moduleName
   put view_GetTemplateObject (moduleName) into rowModule
   --
   object_GoTo rowModule
   display_ModuleTools moduleName, true
end menu_DisplayRowModule

on menu_CreateRowModule dView
   put _ClickedLinkedModuleName (dView) into moduleName
   --
   put LocalArray ["displayView"] into displayView
   put lcw_Ask ("Do you want to create a new module for this row?", moduleName, displayView) into moduleName
   put view_GetTemplateObject (moduleName) into rowTemplate
   if exists (rowModule) then
      lcw_AnswerWarning  "A view or module called '[[moduleName]] already exists!", displayView, moduleName
   end if
   --
   put module_ConstructFolder (moduleName, "lcw_Wiki") into moduleFolder
   module_Create moduleFolder, moduleName
   put the result into resultArray
   --
   go to stack moduleName
   save stack moduleName
   display_ModuleTools moduleName, true
   --
   put resultArray ["moduleHomeStackPath"] into moduleHomeStackPath
   put resultArray ["moduleBehaviorStackPath"] into moduleBehaviorStackPath
   put resultArray ["moduleControllerStackPath"] into moduleControllerStackPath
end menu_CreateRowModule

on menu_CreateDialogue
   local pTargetCard, pBehavior, pRowStyleTemplateGroupsA
   --
   put _HelperTargetStackName() into helperTargetStackName
   toplevel stack helperTargetStackName
   --
   -- dvIdeCreateDataViewControlUsingDialog pTargetCard, pBehavior, pRowStyleTemplateGroupsA
   levure_CreateDataViewDialog
   put it into dView
   --
   levure_SetData dView
end menu_CreateDialogue

on menu_CreateDataView dView
   put "LexonWiki DataView" into pName
   --
   put the long id of stack "DataView Array Controller Behavior" into pBehavior
   --
   put _HelperTargetStackName() into helperTargetStackName
   put the long id of card 1 of stack helperTargetStackName into pTargetCard
   --
   dvIdeCreateDataViewControl pName, pTargetCard, pBehavior
   --
   put "Line 1" into tA[1]["label"]
   put "Line 2" into tA[2]["label"]
   put "Line 3" into tA[3]["label"]
   put "Line 4" into tA[4]["label"]
   --
   set the dvData of group pName of stack helperTargetStackName to tA
end menu_CreateDataView

on _
end _

on menu_SetLinkedDataView dView
   put the selectedObject into someContainer
   if someContainer is empty then
      put the long id of the current card of the topStack into someContainer
   end if
   --
   put the dv_Controls of someContainer into dvControls
   put line 1 of dvControls into dView
   
   put the short id of dView into dvID
   put the stack_Name of someContainer into stackName
   select group id dvID of stack stackName
   
   lcw_Answer "Do you want to set the linked dataview of this menu to the selectedobj?"
   --
   breakpoint
   set the dv_LinkedDataView of dView to dView
   --
   put the card_Object of dView into cObject
   set the dv_LinkedDataView of cObject to dView
   --
   put LocalArray ["displayView"] into displayView
   if exists (displayView) is true then
      set the dv_LinkedDataView of displayView to dView
   end if
end menu_SetLinkedDataView

on menu_Deselect
   select empty
end menu_Deselect

on menu_RefreshDataView dView
   dispatch "ResetView" to dView
   dispatch "RenderView" to dView
end menu_RefreshDataView

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Props
-
getprop goToLexonView_Params
   return "Wiki Row Templates 2"
end goToLexonView_Params

getprop edit_Params
   put the mainstacks into sNames
   filter sNames with "*DataView*"
   return sNames
end edit_Params


--> Dev | Menu
-
on menu_GoToLexonView dView, stackName
   go to stack stackName
end menu_GoToLexonView

on _
end _

on menu_HelperTargetStackName dView, helperTargetStackName
   put helperTargetStackName into LocalArray ["helperTargetStackName"]
end menu_HelperTargetStackName

on menu_StackIsKnown dView
   put _HelperTargetStackName() into helperTargetStackName
   put the stack_IsKnown of stack helperTargetStackName into isKnown
   --
   set the stack_IsKnown of stack helperTargetStackName to (isKnown is false)
end menu_StackIsKnown

on _
end _

on menu_Edit displayView, stackName
   edit the script of stack stackName
end menu_Edit

on menu_EditWikiBehavior
   edit the script of stack "Wiki Behavior"
end menu_EditWikiBehavior

on menu_EditDataViewBehavior
   edit the script of stack "DataView Behavior"
end menu_EditDataViewBehavior

on menu_EditHelperLibrary displayView
   edit the script of stack "DataView IDE Helper Library"
end menu_EditHelperLibrary

on menu_RowStyleParams dView
   put the dv_RowStyleNames of dView into styleNames
   --
   display_Data dvRowStyleArray
end menu_RowStyleParams
