#!/bin/bash
set -e

echo_message() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

# Variables
RUN_SCRIPT="/usr/local/bin/run_double_commander.sh"
DESKTOP_ENTRY="$HOME/.local/share/applications/double_commander.desktop"
LAUNCH_SCRIPT="$HOME/bin/launch-desktop.sh"
CONFIG_DIR="$HOME/.config/doublecmd"

# Ensure required directories exist
sudo mkdir -p /usr/share/desktop-directories/
mkdir -p "$CONFIG_DIR"
mkdir -p "$(dirname $DESKTOP_ENTRY)"
mkdir -p "$(dirname $LAUNCH_SCRIPT)"

# Install required packages
echo_message "Installing required packages..."
sudo apt-get update
sudo apt-get install -y doublecmd-qt || { echo_message "Failed to install Double Commander."; exit 1; }

# Create a script to set DISPLAY and run Double Commander
echo_message "Creating run script to set DISPLAY variable and use system's Double Commander..."
sudo tee $RUN_SCRIPT > /dev/null << EOF
#!/bin/bash
export DISPLAY=\$(ip route show default | awk '/default/ {print \$3}'):0.0
exec doublecmd
EOF

sudo chmod +x $RUN_SCRIPT || { echo_message "Failed to create run script."; exit 1; }

# Create a desktop entry
echo_message "Creating desktop entry..."
tee $DESKTOP_ENTRY > /dev/null << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Double Commander
Icon=utilities-terminal
Exec=$RUN_SCRIPT
Comment=Lightweight file manager
Categories=Utility;FileManager;
Terminal=false
EOF

chmod +r $DESKTOP_ENTRY || { echo_message "Failed to create desktop entry."; exit 1; }

# Create a helper script to launch .desktop files with gtk-launch
echo_message "Creating helper script to launch .desktop files with gtk-launch..."
tee $LAUNCH_SCRIPT > /dev/null << EOF
#!/bin/bash

if [ \$# -eq 0 ]; then
    echo "Usage: \$0 <path-to-desktop-file>"
    exit 1
fi

desktop_file="\$1"
app_name=\$(basename "\$desktop_file" .desktop)

gtk-launch "\$app_name"
EOF

chmod +x $LAUNCH_SCRIPT || { echo_message "Failed to create helper script."; exit 1; }

# Create a basic Double Commander configuration file with the file association and default path
echo_message "Creating Double Commander configuration..."
tee $CONFIG_DIR/extassoc.xml > /dev/null << EOF
<?xml version="1.0" encoding="UTF-8"?>
<doublecmd DCVersion="1.0.10">
  <ExtensionAssociation>
    <FileType>
      <Name>desktop</Name>
      <IconFile>/home/user/bin/launch-desktop.sh</IconFile>
      <ExtensionList>desktop</ExtensionList>
      <Actions>
        <Action>
          <Name>Open with launch-desktop.sh</Name>
          <Command>/home/user/bin/launch-desktop.sh</Command>
          <Params>%f</Params>
        </Action>
      </Actions>
    </FileType>
  </ExtensionAssociation>
</doublecmd>

EOF

tee $CONFIG_DIR/doublecmd.xml > /dev/null << EOF
<?xml version="1.0" encoding="UTF-8"?>
<doublecmd DCVersion="1.0.10" ConfigVersion="13">
  <Toolbars>
    <MainToolbar>
      <Row>
        <Command>
          <ID>{031465C7-4614-4B9C-94AE-DBDD099BB05D}</ID>
          <Icon>cm_refresh</Icon>
          <Command>cm_Refresh</Command>
        </Command>
        <Command>
          <ID>{7CB98FCC-C8DE-4065-BFF9-1B83B07F2A9B}</ID>
          <Icon>cm_runterm</Icon>
          <Command>cm_RunTerm</Command>
        </Command>
        <Command>
          <ID>{F891776C-3CBB-4007-A2CA-FFA129CE6094}</ID>
          <Icon>cm_options</Icon>
          <Command>cm_Options</Command>
        </Command>
        <Separator>
          <Style>False</Style>
        </Separator>
        <Command>
          <ID>{3EED4E3D-C977-4004-B718-4485D21EAFF7}</ID>
          <Icon>cm_briefview</Icon>
          <Command>cm_BriefView</Command>
        </Command>
        <Command>
          <ID>{B22FB336-EFB3-469E-A0D5-99365C505DFD}</ID>
          <Icon>cm_columnsview</Icon>
          <Command>cm_ColumnsView</Command>
        </Command>
        <Command>
          <ID>{F7ED3E88-4C0B-4F61-87F1-F8E6C3233CED}</ID>
          <Icon>cm_thumbnailsview</Icon>
          <Command>cm_ThumbnailsView</Command>
        </Command>
        <Separator>
          <Style>False</Style>
        </Separator>
        <Command>
          <ID>{7E4B7ECC-7A7D-43E2-9CDD-93BDDAC52B29}</ID>
          <Icon>cm_flatview</Icon>
          <Command>cm_FlatView</Command>
        </Command>
        <Separator>
          <Style>False</Style>
        </Separator>
        <Command>
          <ID>{A13505FC-482A-45DA-A4BB-7D7C5B673D10}</ID>
          <Icon>cm_viewhistoryprev</Icon>
          <Command>cm_ViewHistoryPrev</Command>
        </Command>
        <Command>
          <ID>{C3F5A486-A2BA-4335-BE4E-BCC410C21B3F}</ID>
          <Icon>cm_viewhistorynext</Icon>
          <Command>cm_ViewHistoryNext</Command>
        </Command>
        <Separator>
          <Style>False</Style>
        </Separator>
        <Command>
          <ID>{E2353B1A-71AC-4413-B9AB-3DBF3BD4693D}</ID>
          <Icon>cm_markplus</Icon>
          <Command>cm_MarkPlus</Command>
        </Command>
        <Command>
          <ID>{5C05BF2E-04C2-4A1A-BCDA-68A5ECC069CF}</ID>
          <Icon>cm_markminus</Icon>
          <Command>cm_MarkMinus</Command>
        </Command>
        <Command>
          <ID>{27BB9E20-40CE-4F18-805B-3610A890936E}</ID>
          <Icon>cm_markinvert</Icon>
          <Command>cm_MarkInvert</Command>
        </Command>
        <Separator>
          <Style>False</Style>
        </Separator>
        <Command>
          <ID>{DBB17386-9714-4C7C-9041-5F6445EC844C}</ID>
          <Icon>cm_packfiles</Icon>
          <Command>cm_PackFiles</Command>
        </Command>
        <Command>
          <ID>{25B182CA-AA80-45B6-B237-CC9B81EB13E6}</ID>
          <Icon>cm_extractfiles</Icon>
          <Command>cm_ExtractFiles</Command>
        </Command>
        <Separator>
          <Style>False</Style>
        </Separator>
        <Command>
          <ID>{CF2FA709-72DF-4CF3-B8C8-50DD7BC89EDE}</ID>
          <Icon>cm_search</Icon>
          <Command>cm_Search</Command>
        </Command>
        <Command>
          <ID>{0A7F3716-5E11-4037-887F-73F503C43B10}</ID>
          <Icon>cm_multirename</Icon>
          <Command>cm_MultiRename</Command>
        </Command>
        <Command>
          <ID>{AECF5FCE-6D9B-48A0-BFD7-606BE2FCE295}</ID>
          <Icon>cm_syncdirs</Icon>
          <Command>cm_SyncDirs</Command>
        </Command>
        <Command>
          <ID>{7ACD2073-153D-4B3E-BC02-E0DC97C18B87}</ID>
          <Icon>cm_copyfullnamestoclip</Icon>
          <Command>cm_CopyFullNamesToClip</Command>
        </Command>
      </Row>
    </MainToolbar>
    <MiddleToolbar>
      <Row>
        <Command>
          <ID>{DB6983A9-8DD5-422E-B95B-DBC099512BBE}</ID>
          <Icon>cm_view</Icon>
          <Command>cm_View</Command>
        </Command>
        <Command>
          <ID>{A8288880-A6E0-4792-A675-E17B9AB1C66F}</ID>
          <Icon>cm_edit</Icon>
          <Command>cm_Edit</Command>
        </Command>
        <Command>
          <ID>{D6717EA9-8DB3-443E-A0BC-43C7799CDEF3}</ID>
          <Icon>cm_copy</Icon>
          <Command>cm_Copy</Command>
        </Command>
        <Command>
          <ID>{0298332C-95E3-4F00-A68E-C3D47E5BBA6D}</ID>
          <Icon>cm_rename</Icon>
          <Command>cm_Rename</Command>
        </Command>
        <Separator>
          <Style>True</Style>
        </Separator>
        <Command>
          <ID>{CD51AE21-379E-4C5C-95E7-D337AE394102}</ID>
          <Icon>cm_packfiles</Icon>
          <Command>cm_PackFiles</Command>
        </Command>
        <Command>
          <ID>{D8DEFCB8-F77F-41B6-A921-9D9B128AD4D8}</ID>
          <Icon>cm_makedir</Icon>
          <Command>cm_MakeDir</Command>
        </Command>
      </Row>
    </MiddleToolbar>
  </Toolbars>
  <MainWindow>
    <Position Save="True">
      <Left>0</Left>
      <Top>23</Top>
      <Width>2498</Width>
      <Height>1057</Height>
      <PixelsPerInch>96</PixelsPerInch>
      <Maximized>False</Maximized>
      <Splitter>50</Splitter>
    </Position>
  </MainWindow>
  <Tabs>
    <OpenedTabs>
      <Left>
        <ActiveTab>0</ActiveTab>
        <Tab>
          <FileView Type="columns">
            <History>
              <Entry Active="True">
                <FileSource Type="FileSystem"/>
                <Paths>
                  <Path Filename="..">/usr/lib/doublecmd/</Path>
                  <Path Filename="opt">/</Path>
                  <Path Filename="pycharm">/opt/</Path>
                  <Path Filename="bin">/opt/pycharm/</Path>
                  <Path Filename="pycharm.png">/opt/pycharm/bin/</Path>
                </Paths>
              </Entry>
            </History>
            <ColumnsView>
              <ColumnsSet>Default</ColumnsSet>
            </ColumnsView>
          </FileView>
        </Tab>
      </Left>
      <Right>
        <ActiveTab>0</ActiveTab>
        <Tab>
          <FileView Type="columns">
            <History>
              <Entry Active="True">
                <FileSource Type="FileSystem"/>
                <Paths>
                  <Path Filename="..">/usr/lib/doublecmd/</Path>
                </Paths>
              </Entry>
            </History>
            <ColumnsView>
              <ColumnsSet>Default</ColumnsSet>
            </ColumnsView>
          </FileView>
        </Tab>
      </Right>
    </OpenedTabs>
    <Options>54033</Options>
    <CharacterLimit>32</CharacterLimit>
    <Position>0</Position>
    <ActionOnDoubleClick>2</ActionOnDoubleClick>
  </Tabs>
  <Language>
    <POFileName>doublecmd.en.po</POFileName>
  </Language>
  <Behaviours>
    <GoToRoot>False</GoToRoot>
    <ShowCurDirTitleBar>False</ShowCurDirTitleBar>
    <ActiveRight>False</ActiveRight>
    <RunInTerminalStayOpenCmd>x-terminal-emulator</RunInTerminalStayOpenCmd>
    <RunInTerminalStayOpenParams>-font JetBrainsMono -e sh -c '{command}; echo -n Press ENTER to exit... ; read a'</RunInTerminalStayOpenParams>
    <RunInTerminalCloseCmd>x-terminal-emulator</RunInTerminalCloseCmd>
    <RunInTerminalCloseParams>-font JetBrainsMono -e sh -c {command}</RunInTerminalCloseParams>
    <JustRunTerminal>x-terminal-emulator</JustRunTerminal>
    <JustRunTermParams>-font JetBrainsMono</JustRunTermParams>
    <OnlyOneAppInstance>False</OnlyOneAppInstance>
    <LynxLike>True</LynxLike>
    <FileSizeFormat>0</FileSizeFormat>
    <OperationSizeFormat>0</OperationSizeFormat>
    <HeaderSizeFormat>0</HeaderSizeFormat>
    <FooterSizeFormat>0</FooterSizeFormat>
    <FileSizeDigits>1</FileSizeDigits>
    <HeaderDigits>1</HeaderDigits>
    <FooterDigits>1</FooterDigits>
    <OperationSizeDigits>1</OperationSizeDigits>
    <PersonalizedByte>B</PersonalizedByte>
    <PersonalizedKilo>KB</PersonalizedKilo>
    <PersonalizedMega>MB</PersonalizedMega>
    <PersonalizedGiga>GB</PersonalizedGiga>
    <PersonalizedTera>TB</PersonalizedTera>
    <MinimizeToTray>False</MinimizeToTray>
    <AlwaysShowTrayIcon>False</AlwaysShowTrayIcon>
    <Mouse>
      <Selection Enabled="True">
        <Button>0</Button>
        <IconClick>0</IconClick>
      </Selection>
      <SingleClickStart>0</SingleClickStart>
      <ScrollMode>1</ScrollMode>
      <WheelScrollLines>3</WheelScrollLines>
    </Mouse>
    <AutoFillColumns>False</AutoFillColumns>
    <AutoSizeColumn>1</AutoSizeColumn>
    <CustomColumnsChangeAllColumns>False</CustomColumnsChangeAllColumns>
    <BriefViewFileExtAligned>False</BriefViewFileExtAligned>
    <DateTimeFormat>mm/dd/yy hh:nn:ss</DateTimeFormat>
    <CutTextToColumnWidth>True</CutTextToColumnWidth>
    <ExtendCellWidth>False</ExtendCellWidth>
    <ShowSystemFiles>False</ShowSystemFiles>
    <ListFilesInThread>True</ListFilesInThread>
    <LoadIconsSeparately>True</LoadIconsSeparately>
    <DelayLoadingTabs>True</DelayLoadingTabs>
    <HighlightUpdatedFiles>True</HighlightUpdatedFiles>
    <DriveBlackList/>
    <DriveBlackListUnmounted>False</DriveBlackListUnmounted>
  </Behaviours>
  <Tools>
    <Viewer Enabled="False">
      <Path/>
      <Parameters/>
      <RunInTerminal>False</RunInTerminal>
      <KeepTerminalOpen>False</KeepTerminalOpen>
    </Viewer>
    <Editor Enabled="False">
      <Path/>
      <Parameters/>
      <RunInTerminal>False</RunInTerminal>
      <KeepTerminalOpen>False</KeepTerminalOpen>
    </Editor>
    <Differ Enabled="False">
      <Path/>
      <Parameters/>
      <RunInTerminal>False</RunInTerminal>
      <KeepTerminalOpen>False</KeepTerminalOpen>
      <FramePosAfterComp>0</FramePosAfterComp>
    </Differ>
  </Tools>
  <Fonts>
    <Main>
      <Name>default</Name>
      <Size>10</Size>
      <Style>1</Style>
      <Quality>0</Quality>
    </Main>
    <Editor>
      <Name>Monospace</Name>
      <Size>14</Size>
      <Style>0</Style>
      <Quality>0</Quality>
    </Editor>
    <Viewer>
      <Name>Monospace</Name>
      <Size>14</Size>
      <Style>0</Style>
      <Quality>0</Quality>
    </Viewer>
    <ViewerBook>
      <Name>default</Name>
      <Size>16</Size>
      <Style>1</Style>
      <Quality>0</Quality>
    </ViewerBook>
    <Log>
      <Name>Monospace</Name>
      <Size>12</Size>
      <Style>0</Style>
      <Quality>0</Quality>
    </Log>
    <Console>
      <Name>Monospace</Name>
      <Size>12</Size>
      <Style>0</Style>
      <Quality>0</Quality>
    </Console>
    <PathEdit>
      <Name>default</Name>
      <Size>10</Size>
      <Style>0</Style>
      <Quality>0</Quality>
    </PathEdit>
    <FunctionButtons>
      <Name>default</Name>
      <Size>10</Size>
      <Style>0</Style>
      <Quality>0</Quality>
    </FunctionButtons>
    <SearchResults>
      <Name>default</Name>
      <Size>10</Size>
      <Style>0</Style>
      <Quality>0</Quality>
    </SearchResults>
    <TreeViewMenu>
      <Name>default</Name>
      <Size>10</Size>
      <Style>0</Style>
      <Quality>0</Quality>
    </TreeViewMenu>
  </Fonts>
  <Colors>
    <UseCursorBorder>False</UseCursorBorder>
    <CursorBorderColor>-2147483635</CursorBorderColor>
    <UseFrameCursor>False</UseFrameCursor>
    <Foreground>-2147483640</Foreground>
    <Background>-2147483643</Background>
    <Background2>-2147483643</Background2>
    <Cursor>-2147483635</Cursor>
    <CursorText>-2147483634</CursorText>
    <Mark>255</Mark>
    <InactiveCursor>-2147483645</InactiveCursor>
    <InactiveMark>128</InactiveMark>
    <UseInvertedSelection>False</UseInvertedSelection>
    <UseInactiveSelColor>False</UseInactiveSelColor>
    <AllowOverColor>True</AllowOverColor>
    <gBorderFrameWidth>1</gBorderFrameWidth>
    <PathLabel>
      <ActiveColor>-2147483635</ActiveColor>
      <ActiveFontColor>-2147483634</ActiveFontColor>
      <InactiveColor>-2147483633</InactiveColor>
      <InactiveFontColor>-2147483630</InactiveFontColor>
    </PathLabel>
    <InactivePanelBrightness>100</InactivePanelBrightness>
    <FreeSpaceIndicator>
      <UseGradient>True</UseGradient>
      <ForeColor>0</ForeColor>
      <BackColor>16777215</BackColor>
    </FreeSpaceIndicator>
    <LogWindow>
      <Info>8388608</Info>
      <Error>255</Error>
      <Success>32768</Success>
    </LogWindow>
    <FileFilters/>
  </Colors>
  <ToolTips>
    <ShowToolTipMode>True</ShowToolTipMode>
    <ActualToolTipMode>0</ActualToolTipMode>
    <ToolTipHideTimeOut>0</ToolTipHideTimeOut>
    <CustomFields/>
  </ToolTips>
  <Layout>
    <MainMenu>True</MainMenu>
    <ButtonBar Enabled="True">
      <FlatIcons>True</FlatIcons>
      <ButtonHeight>24</ButtonHeight>
      <IconSize>16</IconSize>
      <ShowCaptions>False</ShowCaptions>
      <ReportErrorWithCommands>False</ReportErrorWithCommands>
      <FilenameStyle>0</FilenameStyle>
      <PathToBeRelativeTo>%COMMANDER_PATH%</PathToBeRelativeTo>
      <PathModifierElements>0</PathModifierElements>
    </ButtonBar>
    <MiddleBar Enabled="False">
      <FlatIcons>True</FlatIcons>
      <ButtonHeight>24</ButtonHeight>
      <IconSize>16</IconSize>
      <ShowCaptions>False</ShowCaptions>
      <ReportErrorWithCommands>False</ReportErrorWithCommands>
    </MiddleBar>
    <DriveBar1>True</DriveBar1>
    <DriveBar2>True</DriveBar2>
    <DriveBarFlat>True</DriveBarFlat>
    <DrivesListButton Enabled="True">
      <ShowLabel>True</ShowLabel>
      <ShowFileSystem>True</ShowFileSystem>
      <ShowFreeSpace>True</ShowFreeSpace>
    </DrivesListButton>
    <SeparateTree>False</SeparateTree>
    <DirectoryTabs>True</DirectoryTabs>
    <CurrentDirectory>True</CurrentDirectory>
    <TabHeader>True</TabHeader>
    <StatusBar>True</StatusBar>
    <CmdLine>True</CmdLine>
    <LogWindow>False</LogWindow>
    <TermWindow>False</TermWindow>
    <KeyButtons>True</KeyButtons>
    <InterfaceFlat>True</InterfaceFlat>
    <DriveFreeSpace>True</DriveFreeSpace>
    <DriveIndicator>False</DriveIndicator>
    <ProgressInMenuBar>False</ProgressInMenuBar>
    <PanelOfOperationsInBackground>True</PanelOfOperationsInBackground>
    <HorizontalFilePanels>False</HorizontalFilePanels>
    <ShortFormatDriveInfo>True</ShortFormatDriveInfo>
    <UppercaseDriveLetter>False</UppercaseDriveLetter>
    <ShowColonAfterDrive>False</ShowColonAfterDrive>
  </Layout>
  <FilesViews>
    <Sorting>
      <CaseSensitivity>0</CaseSensitivity>
      <NaturalSorting>False</NaturalSorting>
      <SpecialSorting>False</SpecialSorting>
      <SortFolderMode>1</SortFolderMode>
      <NewFilesPosition>2</NewFilesPosition>
      <UpdatedFilesPosition>2</UpdatedFilesPosition>
    </Sorting>
    <ColumnsView>
      <AutoSaveWidth>True</AutoSaveWidth>
      <TitleStyle>2</TitleStyle>
    </ColumnsView>
    <BriefView>
      <FileExtAligned>False</FileExtAligned>
      <Columns>
        <FixedWidth>100</FixedWidth>
        <FixedCount>2</FixedCount>
        <AutoSize>2</AutoSize>
      </Columns>
    </BriefView>
    <ExtraLineSpan>2</ExtraLineSpan>
    <FolderPrefix>[</FolderPrefix>
    <FolderPostfix>]</FolderPostfix>
  </FilesViews>
  <Keyboard>
    <Typing>
      <Actions>
        <NoModifier>2</NoModifier>
        <Alt>0</Alt>
        <CtrlAlt>3</CtrlAlt>
      </Actions>
    </Typing>
  </Keyboard>
  <FileOperations>
    <BufferSize>524288</BufferSize>
    <LongNameAlert>True</LongNameAlert>
    <HashBufferSize>8388608</HashBufferSize>
    <UseMmapInSearch>False</UseMmapInSearch>
    <PartialNameSearch>True</PartialNameSearch>
    <InitiallyClearFileMask>True</InitiallyClearFileMask>
    <NewSearchClearFiltersAction>0</NewSearchClearFiltersAction>
    <ShowMenuBarInFindFiles>True</ShowMenuBarInFindFiles>
    <WipePassNumber>1</WipePassNumber>
    <DropReadOnlyFlag>False</DropReadOnlyFlag>
    <ProcessComments>False</ProcessComments>
    <RenameSelOnlyName>False</RenameSelOnlyName>
    <ShowCopyTabSelectPanel>False</ShowCopyTabSelectPanel>
    <UseTrash>True</UseTrash>
    <SkipFileOpError>False</SkipFileOpError>
    <TypeOfDuplicatedRename>0</TypeOfDuplicatedRename>
    <ShowDialogOnDragDrop>True</ShowDialogOnDragDrop>
    <DragAndDropTextRichtextDesireLevel>0</DragAndDropTextRichtextDesireLevel>
    <DragAndDropTextHtmlDesireLevel>1</DragAndDropTextHtmlDesireLevel>
    <DragAndDropTextUnicodeDesireLevel>2</DragAndDropTextUnicodeDesireLevel>
    <DragAndDropTextSimpletextDesireLevel>3</DragAndDropTextSimpletextDesireLevel>
    <DragAndDropAskFormatEachTime>False</DragAndDropAskFormatEachTime>
    <DragAndDropTextAutoFilename>False</DragAndDropTextAutoFilename>
    <DragAndDropSaveUnicodeTextInUFT8>True</DragAndDropSaveUnicodeTextInUFT8>
    <NtfsHourTimeDelay>False</NtfsHourTimeDelay>
    <AutoExtractOpenMask/>
    <SearchDefaultTemplate/>
    <ProgressKind>0</ProgressKind>
    <Confirmations>15</Confirmations>
    <Options>
      <Symlink>0</Symlink>
      <CorrectLinks>False</CorrectLinks>
      <CopyOnWrite>2</CopyOnWrite>
      <FileExists>0</FileExists>
      <DirectoryExists>0</DirectoryExists>
      <SetPropertyError>0</SetPropertyError>
      <ReserveSpace>True</ReserveSpace>
      <CheckFreeSpace>True</CheckFreeSpace>
      <CopyAttributes>True</CopyAttributes>
      <CopyXattributes>True</CopyXattributes>
      <Verify>False</Verify>
      <CopyTime>True</CopyTime>
      <CopyOwnership>False</CopyOwnership>
      <CopyPermissions>False</CopyPermissions>
      <ExcludeEmptyTemplateDirectories>True</ExcludeEmptyTemplateDirectories>
    </Options>
    <Extract>
      <Overwrite>False</Overwrite>
    </Extract>
    <MultiRename>
      <MulRenShowMenuBarOnTop>True</MulRenShowMenuBarOnTop>
      <MulRenInvalidCharReplacement>.</MulRenInvalidCharReplacement>
      <MulRenLaunchBehavor>0</MulRenLaunchBehavor>
      <MulRenExitModifiedPreset>0</MulRenExitModifiedPreset>
      <MulRenSaveRenamingLog>0</MulRenSaveRenamingLog>
      <MulRenLogFilename>%DC_CONFIG_PATH%/multirename.log</MulRenLogFilename>
      <MultRenDailyIndividualDirLog>True</MultRenDailyIndividualDirLog>
      <MulRenFilenameWithFullPathInLog>False</MulRenFilenameWithFullPathInLog>
      <MulRenPathRangeSeparator>- </MulRenPathRangeSeparator>
    </MultiRename>
  </FileOperations>
  <Log Enabled="False" Count="0" LogFileWithDateInName="False">
    <FileName>%DC_CONFIG_PATH%/doublecmd.log</FileName>
    <Options>1023</Options>
  </Log>
  <Configuration Save="True" SortOrder="1" TreeType="0">
    <FolderTabs Save="True"/>
  </Configuration>
  <History>
    <SearchReplaceHistory Save="True"/>
    <DirHistory Save="True"/>
    <CmdLineHistory Save="True"/>
    <FileMaskHistory Save="True"/>
  </History>
  <QuickSearch>
    <MatchBeginning>True</MatchBeginning>
    <MatchEnding>True</MatchEnding>
    <Case>1</Case>
    <Items>2</Items>
  </QuickSearch>
  <QuickFilter>
    <AutoHide>True</AutoHide>
    <SaveSessionModifications>False</SaveSessionModifications>
  </QuickFilter>
  <Miscellaneous>
    <GridVertLine>False</GridVertLine>
    <GridHorzLine>False</GridHorzLine>
    <ShowWarningMessages>True</ShowWarningMessages>
    <SpaceMovesDown>False</SpaceMovesDown>
    <DirBrackets>True</DirBrackets>
    <InplaceRename>False</InplaceRename>
    <InplaceRenameButton>True</InplaceRenameButton>
    <DblClickToParent>False</DblClickToParent>
    <HotDirAddTargetOrNot>False</HotDirAddTargetOrNot>
    <HotDirFullExpandOrNot>False</HotDirFullExpandOrNot>
    <ShowPathInPopup>False</ShowPathInPopup>
    <ShowOnlyValidEnv>True</ShowOnlyValidEnv>
    <WhereToAddNewHotDir>2</WhereToAddNewHotDir>
    <FilenameStyle>0</FilenameStyle>
    <PathToBeRelativeTo>%COMMANDER_PATH%</PathToBeRelativeTo>
    <PathModifierElements>0</PathModifierElements>
    <DefaultTextEncoding>none</DefaultTextEncoding>
  </Miscellaneous>
  <Thumbnails Save="True">
    <Width>128</Width>
    <Height>128</Height>
  </Thumbnails>
  <Description>
    <CreateNewUnicode>True</CreateNewUnicode>
    <DefaultEncoding>2</DefaultEncoding>
    <CreateNewEncoding>3</CreateNewEncoding>
  </Description>
  <AutoRefresh>
    <Options>3</Options>
    <ExcludeDirs/>
    <Mode>1</Mode>
  </AutoRefresh>
  <Icons>
    <Theme>dctheme</Theme>
    <ShowHiddenDimmed>False</ShowHiddenDimmed>
    <ShowMode>3</ShowMode>
    <ShowOverlays>False</ShowOverlays>
    <Size>32</Size>
    <DiskSize>16</DiskSize>
    <DiskAlpha>50</DiskAlpha>
    <ToolSize>24</ToolSize>
    <Exclude>False</Exclude>
    <ExcludeDirs/>
    <CustomIcons>0</CustomIcons>
    <PixelsPerInch>96</PixelsPerInch>
    <ShowInMenus Enabled="False">
      <Size>16</Size>
    </ShowInMenus>
    <ShowButtonGlyphs>0</ShowButtonGlyphs>
  </Icons>
  <IgnoreList Enabled="False">
    <IgnoreListFile>%DC_CONFIG_PATH%/ignorelist.txt</IgnoreListFile>
  </IgnoreList>
  <DirectoryHotList/>
  <Viewer>
    <PreviewVisible>False</PreviewVisible>
    <ImageStretch>False</ImageStretch>
    <ImageExifRotate>True</ImageExifRotate>
    <ImageStretchLargeOnly>True</ImageStretchLargeOnly>
    <ImageCenter>True</ImageCenter>
    <CopyMovePath1/>
    <CopyMovePath2/>
    <CopyMovePath3/>
    <CopyMovePath4/>
    <CopyMovePath5/>
    <PaintMode>0</PaintMode>
    <PaintWidth>5</PaintWidth>
    <NumberOfColumns>1</NumberOfColumns>
    <TabSpaces>8</TabSpaces>
    <MaxTextWidth>1024</MaxTextWidth>
    <ViewerMode>0</ViewerMode>
    <PrintMargins>200|200|200|200</PrintMargins>
    <ShowCaret>False</ShowCaret>
    <LeftMargin>4</LeftMargin>
    <ExtraLineSpan>0</ExtraLineSpan>
    <PaintColor>255</PaintColor>
    <BackgroundColor>0</BackgroundColor>
    <FontColor>16777215</FontColor>
    <TextPosition>0</TextPosition>
  </Viewer>
  <Editor>
    <EditWaitTime>2000</EditWaitTime>
    <SynEditOptions>856075</SynEditOptions>
    <SynEditTabWidth>8</SynEditTabWidth>
    <SynEditRightEdge>80</SynEditRightEdge>
  </Editor>
  <Differ>
    <IgnoreCase>False</IgnoreCase>
    <AutoCompare>True</AutoCompare>
    <KeepScrolling>True</KeepScrolling>
    <PaintBackground>True</PaintBackground>
    <LineDifferences>False</LineDifferences>
    <IgnoreWhiteSpace>False</IgnoreWhiteSpace>
    <Colors>
      <Added>11206570</Added>
      <Deleted>11184895</Deleted>
      <Modified>16755370</Modified>
      <Binary>
        <Modified>255</Modified>
      </Binary>
    </Colors>
  </Differ>
  <SyncDirs>
    <Subdirs>False</Subdirs>
    <ByContent>False</ByContent>
    <Asymmetric Save="False">False</Asymmetric>
    <IgnoreDate>False</IgnoreDate>
    <FilterCopyRight>True</FilterCopyRight>
    <FilterEqual>True</FilterEqual>
    <FilterNotEqual>True</FilterNotEqual>
    <FilterCopyLeft>True</FilterCopyLeft>
    <FilterDuplicates>True</FilterDuplicates>
    <FilterSingles>True</FilterSingles>
    <FileMask>*</FileMask>
    <Colors>
      <Left>32768</Left>
      <Right>16711680</Right>
      <Unknown>255</Unknown>
    </Colors>
  </SyncDirs>
  <InternalAssociations>
    <OfferToAddNewFileType>False</OfferToAddNewFileType>
    <LastCustomAction>Custom action</LastCustomAction>
    <ExpandedContextMenu>False</ExpandedContextMenu>
    <ExecuteViaShell>False</ExecuteViaShell>
    <OpenSystemWithTerminalClose>False</OpenSystemWithTerminalClose>
    <OpenSystemWithTerminalStayOpen>False</OpenSystemWithTerminalStayOpen>
    <IncludeFileAssociation>False</IncludeFileAssociation>
    <FilenameStyle>0</FilenameStyle>
    <PathToBeRelativeTo>%COMMANDER_PATH%</PathToBeRelativeTo>
    <PathModifierElements>0</PathModifierElements>
  </InternalAssociations>
  <TreeViewMenu>
    <UseTVMDirectoryHotlistFMC>False</UseTVMDirectoryHotlistFMC>
    <UseTVMDirectoryHotlistFDC>False</UseTVMDirectoryHotlistFDC>
    <UseTVMFavoriteTabsFMC>False</UseTVMFavoriteTabsFMC>
    <UseTVMFavoriteTabsFDC>False</UseTVMFavoriteTabsFDC>
    <UseTVMDirHistory>False</UseTVMDirHistory>
    <UseTVMViewHistory>False</UseTVMViewHistory>
    <UseTVMCommandLineHistory>False</UseTVMCommandLineHistory>
    <TreeViewMenuShortcutExit>True</TreeViewMenuShortcutExit>
    <TreeViewMenuSingleClickExit>True</TreeViewMenuSingleClickExit>
    <TreeViewMenuDoubleClickExit>True</TreeViewMenuDoubleClickExit>
    <Context00>
      <CaseSensitive>False</CaseSensitive>
      <IgnoreAccents>True</IgnoreAccents>
      <ShowWholeBranchIfMatch>False</ShowWholeBranchIfMatch>
    </Context00>
    <Context01>
      <CaseSensitive>False</CaseSensitive>
      <IgnoreAccents>True</IgnoreAccents>
      <ShowWholeBranchIfMatch>False</ShowWholeBranchIfMatch>
    </Context01>
    <Context02>
      <CaseSensitive>False</CaseSensitive>
      <IgnoreAccents>True</IgnoreAccents>
      <ShowWholeBranchIfMatch>False</ShowWholeBranchIfMatch>
    </Context02>
    <Context03>
      <CaseSensitive>False</CaseSensitive>
      <IgnoreAccents>True</IgnoreAccents>
      <ShowWholeBranchIfMatch>False</ShowWholeBranchIfMatch>
    </Context03>
    <Context04>
      <CaseSensitive>False</CaseSensitive>
      <IgnoreAccents>True</IgnoreAccents>
      <ShowWholeBranchIfMatch>False</ShowWholeBranchIfMatch>
    </Context04>
    <Context05>
      <CaseSensitive>False</CaseSensitive>
      <IgnoreAccents>True</IgnoreAccents>
      <ShowWholeBranchIfMatch>False</ShowWholeBranchIfMatch>
    </Context05>
    <Context06>
      <CaseSensitive>False</CaseSensitive>
      <IgnoreAccents>True</IgnoreAccents>
      <ShowWholeBranchIfMatch>False</ShowWholeBranchIfMatch>
    </Context06>
    <TreeViewMenuUseKeyboardShortcut>True</TreeViewMenuUseKeyboardShortcut>
    <BackgroundColor>-2147483617</BackgroundColor>
    <ShortcutColor>255</ShortcutColor>
    <NormalTextColor>-2147483640</NormalTextColor>
    <SecondaryTextColor>-2147483642</SecondaryTextColor>
    <FoundTextColor>-2147483635</FoundTextColor>
    <UnselectableTextColor>-2147483631</UnselectableTextColor>
    <CursorColor>-2147483635</CursorColor>
    <ShortcutUnderCursor>-2147483634</ShortcutUnderCursor>
    <NormalTextUnderCursor>-2147483634</NormalTextUnderCursor>
    <SecondaryTextUnderCursor>-2147483628</SecondaryTextUnderCursor>
    <FoundTextUnderCursor>65535</FoundTextUnderCursor>
    <UnselectableUnderCursor>-2147483631</UnselectableUnderCursor>
  </TreeViewMenu>
  <FavoriteTabsOptions>
    <FavoriteTabsUseRestoreExtraOptions>False</FavoriteTabsUseRestoreExtraOptions>
    <WhereToAdd>1</WhereToAdd>
    <Expand>True</Expand>
    <GotoConfigAftSav>False</GotoConfigAftSav>
    <GotoConfigAftReSav>False</GotoConfigAftReSav>
    <DfltLeftGoTo>0</DfltLeftGoTo>
    <DfltRightGoTo>1</DfltRightGoTo>
    <DfltKeep>5</DfltKeep>
    <DfltSaveDirHistory>False</DfltSaveDirHistory>
    <FavTabsLastUniqueID>{C7608770-ED79-481E-8E0D-37E7C3BBA8D1}</FavTabsLastUniqueID>
  </FavoriteTabsOptions>
  <Lua>
    <PathToLibrary>liblua5.1.so.0</PathToLibrary>
  </Lua>
  <NameShortcutFile>shortcuts.scf</NameShortcutFile>
  <HotKeySortOrder>0</HotKeySortOrder>
  <UseEnterToCloseHotKeyEditor>True</UseEnterToCloseHotKeyEditor>
  <LastUsedPacker>zip</LastUsedPacker>
  <LastDoAnyCommand>cm_Refresh</LastDoAnyCommand>
  <MarkMaskCaseSensitive>False</MarkMaskCaseSensitive>
  <MarkMaskIgnoreAccents>False</MarkMaskIgnoreAccents>
  <MarkMaskFilterWindows>False</MarkMaskFilterWindows>
  <MarkShowWantedAttribute>False</MarkShowWantedAttribute>
  <MarkDefaultWantedAttribute/>
  <MarkLastWantedAttribute/>
  <SearchTemplates/>
  <ColumnsSets DefaultTitleHash="540805403">
    <ColumnsSet UseFrameCursor="False">
      <Name>Default</Name>
      <CustomView>False</CustomView>
      <FileSystem>&lt;General&gt;</FileSystem>
      <PixelsPerInch>96</PixelsPerInch>
      <CursorBorder Enabled="False">
        <Color>0</Color>
      </CursorBorder>
      <Columns>
        <Column>
          <Title>Name</Title>
          <FuncString>[DC().GETFILENAMENOEXT{}]</FuncString>
          <Width>250</Width>
          <Align>0</Align>
          <Font>
            <Name>default</Name>
            <Size>10</Size>
            <Style>1</Style>
            <Quality>0</Quality>
          </Font>
          <TextColor>-2147483640</TextColor>
          <Background>-2147483643</Background>
          <Background2>-2147483643</Background2>
          <MarkColor>255</MarkColor>
          <CursorColor>-2147483635</CursorColor>
          <CursorText>-2147483634</CursorText>
          <InactiveCursorColor>-2147483645</InactiveCursorColor>
          <InactiveMarkColor>128</InactiveMarkColor>
          <UseInvertedSelection>False</UseInvertedSelection>
          <UseInactiveSelColor>False</UseInactiveSelColor>
          <Overcolor>True</Overcolor>
        </Column>
        <Column>
          <Title>Ext</Title>
          <FuncString>[DC().GETFILEEXT{}]</FuncString>
          <Width>50</Width>
          <Align>0</Align>
          <Font>
            <Name>default</Name>
            <Size>10</Size>
            <Style>1</Style>
            <Quality>0</Quality>
          </Font>
          <TextColor>-2147483640</TextColor>
          <Background>-2147483643</Background>
          <Background2>-2147483643</Background2>
          <MarkColor>255</MarkColor>
          <CursorColor>-2147483635</CursorColor>
          <CursorText>-2147483634</CursorText>
          <InactiveCursorColor>-2147483645</InactiveCursorColor>
          <InactiveMarkColor>128</InactiveMarkColor>
          <UseInvertedSelection>False</UseInvertedSelection>
          <UseInactiveSelColor>False</UseInactiveSelColor>
          <Overcolor>True</Overcolor>
        </Column>
        <Column>
          <Title>Size</Title>
          <FuncString>[DC().GETFILESIZE{}]</FuncString>
          <Width>70</Width>
          <Align>1</Align>
          <Font>
            <Name>default</Name>
            <Size>10</Size>
            <Style>1</Style>
            <Quality>0</Quality>
          </Font>
          <TextColor>-2147483640</TextColor>
          <Background>-2147483643</Background>
          <Background2>-2147483643</Background2>
          <MarkColor>255</MarkColor>
          <CursorColor>-2147483635</CursorColor>
          <CursorText>-2147483634</CursorText>
          <InactiveCursorColor>-2147483645</InactiveCursorColor>
          <InactiveMarkColor>128</InactiveMarkColor>
          <UseInvertedSelection>False</UseInvertedSelection>
          <UseInactiveSelColor>False</UseInactiveSelColor>
          <Overcolor>True</Overcolor>
        </Column>
        <Column>
          <Title>Date</Title>
          <FuncString>[DC().GETFILETIME{}]</FuncString>
          <Width>140</Width>
          <Align>1</Align>
          <Font>
            <Name>default</Name>
            <Size>10</Size>
            <Style>1</Style>
            <Quality>0</Quality>
          </Font>
          <TextColor>-2147483640</TextColor>
          <Background>-2147483643</Background>
          <Background2>-2147483643</Background2>
          <MarkColor>255</MarkColor>
          <CursorColor>-2147483635</CursorColor>
          <CursorText>-2147483634</CursorText>
          <InactiveCursorColor>-2147483645</InactiveCursorColor>
          <InactiveMarkColor>128</InactiveMarkColor>
          <UseInvertedSelection>False</UseInvertedSelection>
          <UseInactiveSelColor>False</UseInactiveSelColor>
          <Overcolor>True</Overcolor>
        </Column>
        <Column>
          <Title>Attr</Title>
          <FuncString>[DC().GETFILEATTR{}]</FuncString>
          <Width>100</Width>
          <Align>0</Align>
          <Font>
            <Name>default</Name>
            <Size>10</Size>
            <Style>1</Style>
            <Quality>0</Quality>
          </Font>
          <TextColor>-2147483640</TextColor>
          <Background>-2147483643</Background>
          <Background2>-2147483643</Background2>
          <MarkColor>255</MarkColor>
          <CursorColor>-2147483635</CursorColor>
          <CursorText>-2147483634</CursorText>
          <InactiveCursorColor>-2147483645</InactiveCursorColor>
          <InactiveMarkColor>128</InactiveMarkColor>
          <UseInvertedSelection>False</UseInvertedSelection>
          <UseInactiveSelColor>False</UseInactiveSelColor>
          <Overcolor>True</Overcolor>
        </Column>
      </Columns>
    </ColumnsSet>
  </ColumnsSets>
  <Plugins>
    <DsxPlugins/>
    <WcxPlugins>
      <WcxPlugin Enabled="True">
        <ArchiveExt>zip</ArchiveExt>
        <Path>%commander_path%/plugins/wcx/zip/zip.wcx</Path>
        <Flags>735</Flags>
      </WcxPlugin>
      <WcxPlugin Enabled="True">
        <ArchiveExt>jar</ArchiveExt>
        <Path>%commander_path%/plugins/wcx/zip/zip.wcx</Path>
        <Flags>990</Flags>
      </WcxPlugin>
      <WcxPlugin Enabled="True">
        <ArchiveExt>tar</ArchiveExt>
        <Path>%commander_path%/plugins/wcx/zip/zip.wcx</Path>
        <Flags>223</Flags>
      </WcxPlugin>
      <WcxPlugin Enabled="True">
        <ArchiveExt>bz2</ArchiveExt>
        <Path>%commander_path%/plugins/wcx/zip/zip.wcx</Path>
        <Flags>91</Flags>
      </WcxPlugin>
      <WcxPlugin Enabled="True">
        <ArchiveExt>tbz</ArchiveExt>
        <Path>%commander_path%/plugins/wcx/zip/zip.wcx</Path>
        <Flags>95</Flags>
      </WcxPlugin>
      <WcxPlugin Enabled="True">
        <ArchiveExt>gz</ArchiveExt>
        <Path>%commander_path%/plugins/wcx/zip/zip.wcx</Path>
        <Flags>91</Flags>
      </WcxPlugin>
      <WcxPlugin Enabled="True">
        <ArchiveExt>tgz</ArchiveExt>
        <Path>%commander_path%/plugins/wcx/zip/zip.wcx</Path>
        <Flags>95</Flags>
      </WcxPlugin>
      <WcxPlugin Enabled="True">
        <ArchiveExt>lzma</ArchiveExt>
        <Path>%commander_path%/plugins/wcx/zip/zip.wcx</Path>
        <Flags>1</Flags>
      </WcxPlugin>
      <WcxPlugin Enabled="True">
        <ArchiveExt>tlz</ArchiveExt>
        <Path>%commander_path%/plugins/wcx/zip/zip.wcx</Path>
        <Flags>95</Flags>
      </WcxPlugin>
      <WcxPlugin Enabled="True">
        <ArchiveExt>xz</ArchiveExt>
        <Path>%commander_path%/plugins/wcx/zip/zip.wcx</Path>
        <Flags>91</Flags>
      </WcxPlugin>
      <WcxPlugin Enabled="True">
        <ArchiveExt>zst</ArchiveExt>
        <Path>%commander_path%/plugins/wcx/zip/zip.wcx</Path>
        <Flags>91</Flags>
      </WcxPlugin>
      <WcxPlugin Enabled="True">
        <ArchiveExt>txz</ArchiveExt>
        <Path>%commander_path%/plugins/wcx/zip/zip.wcx</Path>
        <Flags>95</Flags>
      </WcxPlugin>
      <WcxPlugin Enabled="True">
        <ArchiveExt>zipx</ArchiveExt>
        <Path>%commander_path%/plugins/wcx/zip/zip.wcx</Path>
        <Flags>223</Flags>
      </WcxPlugin>
      <WcxPlugin Enabled="True">
        <ArchiveExt>cpio</ArchiveExt>
        <Path>%commander_path%/plugins/wcx/cpio/cpio.wcx</Path>
        <Flags>4</Flags>
      </WcxPlugin>
      <WcxPlugin Enabled="True">
        <ArchiveExt>deb</ArchiveExt>
        <Path>%commander_path%/plugins/wcx/deb/deb.wcx</Path>
        <Flags>4</Flags>
      </WcxPlugin>
      <WcxPlugin Enabled="True">
        <ArchiveExt>rpm</ArchiveExt>
        <Path>%commander_path%/plugins/wcx/rpm/rpm.wcx</Path>
        <Flags>4</Flags>
      </WcxPlugin>
      <WcxPlugin Enabled="True">
        <ArchiveExt>rar</ArchiveExt>
        <Path>%commander_path%/plugins/wcx/unrar/unrar.wcx</Path>
        <Flags>607</Flags>
      </WcxPlugin>
    </WcxPlugins>
    <WdxPlugins>
      <WdxPlugin>
        <Name>deb_wdx</Name>
        <Path>%commander_path%/plugins/wdx/deb_wdx/deb_wdx.wdx</Path>
        <DetectString>EXT="DEB"</DetectString>
      </WdxPlugin>
      <WdxPlugin>
        <Name>rpm_wdx</Name>
        <Path>%commander_path%/plugins/wdx/rpm_wdx/rpm_wdx.wdx</Path>
        <DetectString>EXT="RPM"</DetectString>
      </WdxPlugin>
      <WdxPlugin>
        <Name>audioinfo</Name>
        <Path>%commander_path%/plugins/wdx/audioinfo/audioinfo.wdx</Path>
        <DetectString>(EXT="MP3") | (EXT="MP2") | (EXT="MP1") | (EXT="OGG") | (EXT="WMA") | (EXT="WAV") | (EXT="VQF") | (EXT="AAC") | (EXT="APE") | (EXT="MPC") | (EXT="FLAC") | (EXT="CDA") | (EXT="TTA") | (EXT="AC3") | (EXT="DTS") | (EXT="WV") | (EXT="WVC") | (EXT="OFR") | (EXT="OFS") | (EXT="M4A") | (EXT="MP4") | (EXT="OPUS")</DetectString>
      </WdxPlugin>
    </WdxPlugins>
    <WfxPlugins>
      <WfxPlugin Enabled="True">
        <Name>FTP</Name>
        <Path>%commander_path%/plugins/wfx/ftp/ftp.wfx</Path>
      </WfxPlugin>
      <WfxPlugin Enabled="True">
        <Name>Windows Network</Name>
        <Path>%commander_path%/plugins/wfx/samba/samba.wfx</Path>
      </WfxPlugin>
    </WfxPlugins>
    <WlxPlugins/>
    <TweakPluginWidth0>0</TweakPluginWidth0>
    <TweakPluginHeight0>0</TweakPluginHeight0>
    <TweakPluginWidth1>0</TweakPluginWidth1>
    <TweakPluginHeight1>0</TweakPluginHeight1>
    <TweakPluginWidth2>0</TweakPluginWidth2>
    <TweakPluginHeight2>0</TweakPluginHeight2>
    <TweakPluginWidth3>0</TweakPluginWidth3>
    <TweakPluginHeight3>0</TweakPluginHeight3>
    <TweakPluginWidth4>0</TweakPluginWidth4>
    <TweakPluginHeight4>0</TweakPluginHeight4>
    <AutoTweak>False</AutoTweak>
    <WCXConfigViewMode>0</WCXConfigViewMode>
    <PluginFilenameStyle>0</PluginFilenameStyle>
    <PluginPathToBeRelativeTo>%COMMANDER_PATH%</PluginPathToBeRelativeTo>
  </Plugins>
</doublecmd>

EOF

echo_message "Double Commander installation and configuration complete. You can start Double Commander from your application menu or by running 'run_double_commander.sh'."