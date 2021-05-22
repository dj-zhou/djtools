#!/bin/bash

# =============================================================================
function _code_name_help() {
    echo -e "-------------- code-name --------------------"
    echo -e "\r\n TODO\r\n"
}

function _code_name_compuer_name() {
    echo -e "\r\n Computer code names: Types of Snakes\r\n"
    echo "  Anaconda Boa Cobra Copperhead Cottonmouth Garter "
    echo "  Kingsnake Mamba Python Rattler Sidewinder Taipan "
    echo "  Viper"
}

function _code_name_others() {
    echo -e "\r\n Other code names to consider\r\n"
    echo "--------------"
    echo "Weather & Atmosphere:"
    echo "  Aurora Avalanche Blizzard Cyclone Dewdrop Downpour"
    echo "  Duststorm Fogbank Freeze Frost Gully-Washer Gust"
    echo "  Hurricane Ice-Storm Jet-Stream Lightning Mist"
    echo "  Monsoon Rainbow Raindrop Sand-Storm Seabreeze"
    echo "  Snowflake Stratosphere Storm Sunrise Sunset Tornado"
    echo "  Thunder Thunderbolt Thunderstorm Tropical-Storm"
    echo "  Twister Typhoon Updraft Vortex Waterspout Whirlwind"
    echo "  Wind-Chill"

    echo "--------------"
    echo "Famous Philosophers & Scientists:"
    echo "  Archimedes Aristotle Confucius Copernicus Curie"
    echo "  da-Vinci Darwin Descartes Edison Einstein Epicurus"
    echo "  Freud Galileo Hawking Machiavelli Marx Newton Pascal"
    echo "  Pasteur Plato Sagan Socrates Tesla Voltaire"

    echo "--------------"
    echo "Games:"
    echo "  Baccarat Backgammon Blackjack Chess Jenga Jeopardy"
    echo "  Keno Monopoly Pictionary Poker Scrabble Trivial-Pursuit"
    echo "  Twister Roulette Stratego Yahtzee"

    echo "--------------"
    echo "Superheros:"
    echo "  Aquaman Batman Black-Panther Black-Widow Captain-America"
    echo "  Catwoman Daredevil Dr.-Strange Flash Green-Arrow"
    echo "  Green-Lantern Hulk Iron-Man Phantom Thor Silver-Surfer"
    echo "  Spider-Man Supergirl Superman Wonder-Woman Wolverine"

    echo "--------------"
    echo "Members of the Horse Family:"
    echo "  Amiatina Andalusian Appaloosa Clydesdale Colt Falabella"
    echo "  Knabstrupper Lipizzan Lucitano Maverick Mustang Palomino"
    echo "  Pony Quarter-Horse Stallion Thoroughbred Zebra"

    echo "--------------"
    echo "Tropical Islands:"
    echo "  Antigua Aruba Azores Baja Bali Barbados Bermuda Bora-Bora"
    echo "  Borneo Capri Cayman Corfu Cozumel Curacao Fiji Galapagos"
    echo "  Hawaii Ibiza Jamaica Kauai Lanai Majorca Maldives Maui"
    echo "  Mykonos Nantucket Oahu Tahiti Tortuga Roatan Santorini"
    echo "  Seychelles St.-Johns St.-Lucia"

    echo "--------------"
    echo "Types of Birds:"
    echo "  Albatross Bald-Eagle Blackhawk Blue-Jay Chukar Condor"
    echo "  Crane Dove Eagle Falcon Goose Grouse Hawk Heron Hornbill"
    echo "  Hummingbird Lark Mallard Oriole Osprey Owl Parrot"
    echo "  Penguin Peregrine Pelican Pheasant Quail Raptor Raven"
    echo "  Robin Sandpiper Seagull Sparrow Stork Thunderbird Toucan"
    echo "  Vulture Waterfowl Woodpecker Wren"

    echo "--------------"
    echo "Star Wars:"
    echo "  C-3PO Chewbacca Dagobah Darth-Vader Death-Star Devaron"
    echo "  Droid Endor Ewok Hoth Jakku Jedi-(… Knight, Master, Mind Trick)"
    echo "  Leia Lightsaber Lothal Naboo Padawan R2-D2 Scarif Sith"
    echo "  Skywalker Stormtrooper Tatooine Wookie Yoda Zanbar"

    echo "--------------"
    echo "Types of Boats:"
    echo "  Canoe Catamaran Cruiser Cutter Ferry Galleon Gondola"
    echo "  Hovercraft Hydrofoil Jetski Kayak Longboat Motorboat"
    echo "  Outrigger Pirate-Ship Riverboat Sailboat Skipjack"
    echo "  Schooner Skiff Sloop Steamboat Tanker Trimaran Trawler"
    echo "  Tugboat U-boat Yacht Yawl"

    echo "--------------"
    echo "Feared Water Animals:"
    echo "  Alligator Barracuda Crocodile Gator Great-White"
    echo "  Hammerhead Jaws Lionfish Mako Moray Orca Piranha"
    echo "  Shark Stingray"

    echo "--------------"
    echo "Signs of the Zodiac:"
    echo "  Aquarius Aries Cancer Capricorn Gemini Libra Leo"
    echo "  Pisces Sagittarius Scorpio Taurus Virgo"

    echo "--------------"
    echo "Venomous or Biting Animals (non-snake):"
    echo "  Abispa Andrena Black-Widow Cataglyphis Centipede"
    echo "  Cephalotes Formica Hornet Jellyfish Scorpion"
    echo "  Tarantula Yellowjacket Wasp"

    echo "--------------"
    echo "Greek & Roman Gods:"
    echo "  Apollo Ares Artemis Athena Hercules Hermes"
    echo "  Iris Medusa Nemesis Neptune Perseus Poseidon Triton"
    echo "  Zeus"
}

function _code_name_stm32_dev() {
    echo -e "\r\n STM32 Development code names: Bladed Weapons\r\n"
    echo "  Axe Battle-Axe Bayonet Blade Crossbowe Dagger "
    echo "  Excalibur Halberd Hatchet Machete Saber Samurai "
    echo "  Scimitar Scythe Stiletto Spear Sword"
}

# =============================================================================
function code-name() {
    cur_dir=$PWD

    if [ $# = 0 ]; then
        _code_name_help
        return
    elif [ $1 = '--help' ]; then
        _code_name_help
        return
    elif [ $1 = 'computer-name' ]; then
        _code_name_compuer_name
        return
    elif [ $1 = 'others' ]; then
        _code_name_others
        return
    elif [ $1 = 'stm32-dev' ]; then
        _code_name_stm32_dev
        return
    else
        _code_name_help
        return
    fi

    cd ${cur_dir}
}

# =============================================================================
function _code-name() {
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        computer-name
        others
        stm32-dev
        --help
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # no space in front or after "="
    ACTIONS["computer-name"]=" "
    ACTIONS[others]=" "
    ACTIONS["stm32-dev"]=" "
    ACTIONS[--help]=" "

    # ------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ]; then
        COMPREPLY=($(compgen -W "${ACTIONS[$3]}" -- $cur))
    else
        COMPREPLY=($(compgen -W "${SERVICES[*]}" -- $cur))
    fi
}

# =============================================================================
complete -F _code-name code-name
