script "lib_Levure"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Levure
type: library
version: 0.1


/*Some help*/


--> Working on
--

/*
--> Props
-
getprop dv_LinkedRowStack
   put the dvControl of the target into dView
   if exists (dView) is false then return empty
   
   put the dv_MetadataObject of dView into metadataObject
   put the uLCW ["dv_LinkedRowStack"] of metadataObject into stackName
   return stackName
end dv_LinkedRowStack

setprop dv_LinkedRowStack stackName
   if exists (stack stackName) is false then return "error, stack does not exists:" && stackName
   put the dvControl of the target into dView
   if exists (dView) is false then return empty
   
   put the short name of stack stackName into stackName -- could be a path
   --
   put the dv_MetadataObject of dView into metadataObject
   set the uLCW ["dv_LinkedRowStack"] of metadataObject to stackName
   --
   set the stackFile_Link of dView to stackName
   return metadataObject
end dv_LinkedRowStack
   
getprop dv_LinkedDataView
   put the dv_MetadataObject of the target into metadataObject
   put the uLCW ["dv_LinkedDataView"] of metadataObject into dView
   return dView
end dv_LinkedDataView

setprop dv_LinkedDataView dView
   -- set this for a card, button or dataview to link menus or other tools to a specific instance
   if exists (dView) is false then return "error, dView does not exists:" && dView
   put revRuggedID (dView) into dView
   
   put the dv_MetadataObject of the target into metadataObject
   set the uLCW ["dv_LinkedDataView"] of metadataObject to dView
   return metadataObject
end dv_LinkedDataView

getprop dv_Metadata [someKey]
   put the dv_MetadataObject of the target into metadataObject
   --
   put the uLCW ["dv_Metadata"] of metadataObject into dvMetadata
   if someKey is empty then
      return dvMetadata
   else
      return dvMetadata [someKey]
   end if
end dv_Metadata

setprop dv_Metadata [someKey] someValue
   put the dv_MetadataObject of the target into metadataObject
   --
   if someKey is empty then
      set the uLCW ["dv_Metadata"] of metadataObject to someValue
   else
      put the uLCW ["dv_Metadata"] of metadataObject into dvMetadata
      put someValue into dvMetadata [someKey]
      set the uLCW ["dv_Metadata"] of metadataObject to dvMetadata
   end if
end dv_Metadata

getprop dv_MetadataObject
   -- makes it easy to reference a standard local place to store metadata for a dv 
   put the long id of the target into tObject
   
   put the dvControl of tObject into dView
   if exists (dView) then return dView
   
   put the display_View of tObject into displayView
   if exists (displayView) then return displayView
   
   put the card_Object of tObject into cObject
   return cObject
end dv_MetadataObject


--> Levure
-
getprop dv_Controls
   put the long id of the target into tObject
   switch word 1 of tObject
      case "stack"
         put the long id of the current card of the defaultstack into cardObject
         return _CardDvControls (cardObject)
      case "card"
         return _CardDvControls (tObject)
      default
         return the dv_ControlsWithin of tObject
   end switch
end dv_Controls

getprop dv_ControlsWithin
   -- is it a dvControl or is there a dvControl one level deep within it?
   -- could recurse
   put the long id of the target into tObject
   --
   put the dvControl of tObject into fObject
   switch
      case fObject = tObject
         return fObject
      case fObject is not empty
         return empty
   end switch
   
   put the childControlIDs of tObject into cIDs
   repeat for each line cID in cIDs
      put the dvControl of control id cID of tObject into fObject
      switch fObject
         case empty
         case tObject
            break
         default
            put fObject & CR after fObjects
      end switch
   end repeat
   delete char -1 of fObjects
   return fObjects
end dv_ControlsWithin


--> DataView
-
setprop dv_Wikidomain [pSlug] wikiDomain
   put the dvControl of the target into dView
   if exists (dView) is false then return empty
   
   put the dv_RowStyleNames of dView into styleNames
   put dv_FetchWikiStoryData (wikiDomain, pSlug, styleNames) into storyData
   --
   set the dvData of dView to storyData
   --
   set the dv_Metadata ["wikiDomain"] of dView to wikiDomain
   set the dv_Metadata ["pSlug"] of dView to pSlug
   --
   return storyData
end dv_Wikidomain

function dv_FetchWikiStoryData wikiDomain, pSlug, pStyleNames
   put pageArray_Fetch (wikiDomain, pSlug) into pageArray
   put pageArray ["story"] into storyArray
   repeat for each key itemNum in storyArray
      put storyArray [itemNum]["type"] into itemType
      --
      switch
         case itemType = "paragraph" -- made a mistake in naming of group
            put "text" into storyArray [itemNum]["@style"]
            break
         case itemType is among the lines of pStyleNames
            put itemType into storyArray [itemNum]["@style"]
            break
         default
            put "default" into storyArray [itemNum]["@style"]
      end switch
      delete variable storyArray [itemNum]["type"]
   end repeat
   return storyArray
end dv_FetchWikiStoryData

command dv_TidyHTML @someHTML
   replace "<h1>" with "<h3>" in someHTML 
   replace "</h1>" with "</h3>" in someHTML 
end dv_TidyHTML


--> Private
-
private function _CardDvControls cardObject
   put the groupIDs of cardObject into gIDs
   repeat for each line gID in gIDs
      put the the dv_ControlsWithin of group id gID of cardObject into groupControls
      if groupControls is not empty then
         put groupControls & CR after dvControls
      end if
   end repeat
   delete char -1 of dvControls
   return dvControls
end _CardDvControls
*/
