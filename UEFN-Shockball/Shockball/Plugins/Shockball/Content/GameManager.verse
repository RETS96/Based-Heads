using { /Fortnite.com/FortPlayerUtilities }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
GameManager := class(creative_device):

    @editable
    innerTrigger:mutator_zone_device = mutator_zone_device{}

    @editable
    sound1Player:cinematic_sequence_device= cinematic_sequence_device{}
    @editable
    sound2Player:cinematic_sequence_device= cinematic_sequence_device{}
    @editable
    sound3Player:cinematic_sequence_device= cinematic_sequence_device{}

    @editable
    roundBeginSound:audio_player_device= audio_player_device{}
    @editable
    wastedSound:audio_player_device= audio_player_device{}
    @editable
    roundEndSoundWinner:audio_player_device= audio_player_device{}
    @editable
    roundEndSound:audio_player_device= audio_player_device{}
    @editable
    roundEndSoundLoser:audio_player_device= audio_player_device{}

    # @editable
    # team1PlatformSwapKillTrigger:mutator_zone_device = mutator_zone_device{}
    # @editable
    # team2PlatformSwapKillTrigger:mutator_zone_device = mutator_zone_device{}

    @editable
    scores: score_manager_device = score_manager_device{}

    @editable
    VFXDev:visual_effect_powerup_device = visual_effect_powerup_device{}
    
    @editable
    spawns:[]player_spawner_device = array{}

    @editable
    team1Device:team_settings_and_inventory_device = team_settings_and_inventory_device{}
    @editable
    team2Device:team_settings_and_inventory_device = team_settings_and_inventory_device{}

    teamOneText:text_block = text_block{DefaultTextColor:= color{R:=1.0, G:=1.0, B:=1.0}}
    teamTwoText:text_block = text_block{DefaultTextColor:= color{R:=1.0, G:=1.0, B:=1.0}}

    var TeamUIPerPlayer : [player]?canvas = map{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Self.GetPlayspace().PlayerAddedEvent().Subscribe(SetupHUD)
        
        AllPlayers := GetPlayspace().GetPlayers()
        for (InPlayer : AllPlayers):
            if (FortCharacter := InPlayer.GetFortCharacter[]):
                FortCharacter.EliminatedEvent().Subscribe(WastedSound)
            SetupHUD(InPlayer)
    
        innerTrigger.AgentEntersEvent.Subscribe(Team1Score)

        var song:int = GetRandomInt(0, 2)
        if(song = 0):
            sound2Player.Stop()
            sound3Player.Stop()
        if(song = 1):
            sound1Player.Stop()
            sound3Player.Stop()
        if(song = 2):
            sound2Player.Stop()
            sound1Player.Stop()

        for(Spawn : spawns):
            Spawn.SpawnedEvent.Subscribe(SpawnVFX)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
        # team1PlatformSwapKillTrigger.AgentEntersEvent.Subscribe(Team1Score)
        # team2PlatformSwapKillTrigger.AgentEntersEvent.Subscribe(Team1Score)

        spawn:
            Tick()

    OnEnd<override>():void={
        # roundEndSound.Play()
        sound2Player.Stop()
        sound3Player.Stop()
        sound1Player.Stop()

    }

    WastedSound(Result: elimination_result):void={
        if(Agent := Result.EliminatedCharacter.GetAgent[]):
            wastedSound.Play(Agent)
    }

    SetupHUD<public>(Player: player):void = {
        VFXDev.Pickup(Player)
        teamOneText.SetText(TeamOne())
        teamTwoText.SetText(TeamTwo())
        Teams := GetPlayspace().GetTeamCollection()
        if(Agent := Player.GetFortCharacter[].GetAgent[]):
            if (PlayerUI := GetPlayerUI[Player]):
                if(Teams.IsOnTeam[Agent, Teams.GetTeams()[0]]):       
                    ui := CurrencyUI(teamOneText)
                    PlayerUI.AddWidget(ui)
                    if (set TeamUIPerPlayer[Player] = option{ui}) {}
                if(Teams.IsOnTeam[Agent, Teams.GetTeams()[1]]):       
                    ui := CurrencyUI(teamTwoText)
                    PlayerUI.AddWidget(ui)
                    if (set TeamUIPerPlayer[Player] = option{ui}) {}
            
    }


    Team1Score(Agent:agent):void={
        if (FortCharacter := Agent.GetFortCharacter[]):
            FortCharacter.Damage(100.0)
    }

    SpawnVFX(Agent:agent):void={
        VFXDev.Pickup(Agent)
    }

    TeamOne<localizes>():message="UnderGrounders"
    TeamTwo<localizes>():message="True Believers"

    Tick()<suspends>:void={

        loop:
            Sleep(1.0)
            AllPlayers := GetPlayspace().GetPlayers()

            for(Player : AllPlayers):
                if(Agent := Player.GetFortCharacter[].GetAgent[]):
                    if (FortCharacter := Agent.GetFortCharacter[]):

                        if(FortCharacter.GetTransform().Translation.Z < -28.0):
                            FortCharacter.Damage(100.0)

                        if(innerTrigger.IsInVolume[Agent]):
                            FortCharacter.Damage(100.0)

                        Teams := GetPlayspace().GetTeamCollection()

                        # if(Teams.IsOnTeam[Agent, Teams.GetTeams()[0]]):                        
                        #     if(team1PlatformSwapKillTrigger.IsInVolume[Agent]):
                        #         FortCharacter.Damage(100.0)

                        # if(Teams.IsOnTeam[Agent, Teams.GetTeams()[1]]):
                        #     if(team2PlatformSwapKillTrigger.IsInVolume[Agent]):
                        #         FortCharacter.Damage(100.0)

                    

    }

    CurrencyUI(Text:text_block) : canvas = {
        MyCanvas : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.1, Y := 0.03}, Maximum := vector2{X := 0.1, Y := 0.03}}
                    Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Text
    
                
        return MyCanvas
    }

