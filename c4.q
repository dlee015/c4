\p 5000

tab:enlist `player`query`h`turn!();

createGrid:{((19#.Q.A)," "),'flip (20 19#0),'1+til 20};
grid:createGrid`;

//bolding @hm
// .j.j enlist[`grid]!enlist .[string grid;((::;0);(19;::));{"<b>",x,"</b>"}]
// .[string grid;(::;0);{"<b>",x,"</b>"}]

//////
//functions that client will call to server, assumes all function just sends back raw msg {neg[.z.w] .Q.s x} 
.c4.tab:{neg[.z.w] .Q.s tab;}
.c4.grid:{neg[.z.w] wrapGrid`;}
.c4.run:{runJob {(first x;"J"$1_ x)}x}
//////

wrapGrid:{.j.j enlist[`grid]!enlist ./[string grid;((::;0);(19;::));{"<b>",x,"</b>"}]};

.z.ws:{[x]
	//runs websocket function, apply in dictionary form
	//x should always be a dictionary (`func`arg!(`runJob;x))
	dict:@[.j.k x;`func;`$];
	@[dict`func;dict`arg];
	.z.w "Received function and performed";
	}

.z.wo:{last[a]@("Welcome to CONNECT 4, You are Player ", string count a::neg key[.z.W]);
        if[1=count a;
            last[a]@ raze("Welcome to CONNECT 4, You are Player ", string count a::neg key[.z.W]; "\n\n"; "Please wait for another player to join")
        ];
        if[2=count a;
			random:1? 1 2;
			first[a]@ player1Message random;
            first[a]@wrapGrid`;
			last[a]@ player2Message random;
            last[a]@wrapGrid`;
			tab::enlist `player`query`h`turn!();
            tab::flip `player`lastQuery`h`turn`yourSym!(1+til[2];2#enlist ();a;0N;(#;%));
            tab::update turn:?[player = first random; 1b; 0b] from tab
        ];
      }   

runJob:{$[(all 1=exec turn from tab) & not "Y"=first[x];
			[
			neg[.z.w] warpGrid`;
			:neg[.z.w] endGame`
			];
	
		(all 1=exec turn from tab) & "Y"=first[x];
			[
			grid::createGrid`;
			random:1+rand 2;
			tab::enlist `player`query`h`turn!();
            tab::flip `player`lastQuery`h`turn`yourSym!(1+til[2];2#enlist ();a;0N;(#;%));
            tab::update turn:?[player = first random; 1b; 0b] from tab;
			a@\: newGameCreated[random];
			a@\: wrapGrid`
			];
			@[`validation;x]
		]}
			
validation:{$[first exec turn from tab where h in neg[.z.w];
            [
			neg[.z.w]  wrapGrid`;
            if[(not x[0] in 19#.Q.A) or not x[1] in 1+til[20];
                :neg[.z.w] tryAgain`
              ];
              
            if["S" <> x 0;
                if[0 in grid . (1 + where x[0] in/:grid), x 1;
				   :neg[.z.w] invalidMove`
                   ]
              ];
            
            if[not 0 in grid . (where x[0] in/:grid), x 1;
				:neg[.z.w] positionUsed`
              ];
			  
            grid::.[grid; (where x[0] in/:grid), x 1;: ;first exec yourSym from tab where h in neg[.z.w]];
			if[@[`valCheck;x];
				player:exec player from tab where turn=1;
				tab::update turn:1 from tab;
				a@\:  wrapGrid`;
				: a@\:raze raze("Game Over! Player ",string player, " has won! Would you like to restart? Y/N")
				];
            tab:: update lastQuery:enlist[x] from tab where h in neg[.z.w];
            tab:: update turn: (not exec turn from tab) from tab;
            a@\:playersTurn`;
			a@\:wrapGrid`
            ];

            :neg[.z.w] wrongTurn`
        ]}

///Validation Messages///
tryAgain:{raze("Invalid Input, Please try again")};
invalidMove:{raze("Invalid Move, bottom row not filled")};
positionUsed:{raze("Position is already used, Please try again")};
playersTurn:{raze ("\n\n"; raze "It is now Player ",(string exec player from tab where turn=1),"'s turn to move")};
wrongTurn:{raze("Not your turn")};
endGame:{raze ("Game has ended, please enter Y if you would like to restart")};
player1Message:{raze("Welcome to CONNECT 4, You are Player 1"; "\n\n"; "There are 2 players, the game will now commence"; "\n\n"; "Instructions"; "\n\n"; "To begin, enter your coordinates"; " starting with your alphabet, followed by your number Eg S11"; "\n\n";raze "Player ",string x, " has been randomly chosen to start first")};
player2Message:{raze("Welcome to CONNECT 4, You are Player 2"; "\n\n"; "There are 2 players, the game will now commence"; "\n\n"; "Instructions"; "\n\n"; "To begin, enter your coordinates"; " starting with your alphabet, followed by your number Eg S11"; "\n\n";raze "Player ",string x, " has been randomly chosen to start first")};
newGameCreated:{raze raze ("A new game is created!"; "\n\n"; "Player ",string x, " has been randomly selected to start first!")};

//Square created of selected points, 0-8 where 4 will be point selected
// 0 1 2 
// 3 4 5
// 6 7 8

//Square check//
valCheck:{win:0b;
		coord: raze (where x[0] in/:grid; x 1);
		sq: {raze first[x] ,/:\: last[x]} {flip (x-1; x; x+1)} coord;
		sym:string exec yourSym from tab where turn=1;
		ind: where (raze/) sym in/: string grid ./:sq;
		
		yAxisUp:$[0 < coord 0; 1b; 0b];
		yAxis2Up:$[1 < coord 0; 1b; 0b];
		yAxisDown:$[18 > coord 0; 1b; 0b];
		yAxis2Down:$[17 > coord 0; 1b; 0b];
		xAxisLeft:$[1 < coord 1; 1b; 0b];
		xAxis2Left:$[2 < coord 1; 1b; 0b];
		xAxisRight:$[20 > coord 1; 1b; 0b];
		xAxis2Right:$[19 > coord 1; 1b; 0b];
		
		// Validation checks based on where index are same as 4 (selected point)
		if[(0 in ind) & not 8 in ind;
			if[yAxis2Up & xAxis2Left;
				if[all (raze/) sym in/: string grid ./: {(-3+x; -2+x)} coord;
					:1b]]];

		if[all 0 8 in ind;
			if[(yAxisUp & xAxisLeft) or (yAxisDown & xAxisRight);
				if[any (raze/) sym in/: string grid ./: {(-2+x;2+x)} coord;
					:1b]]];

		if[(8 in ind) & not 0 in ind;
			if[yAxis2Down & xAxis2Right;
				if[all (raze/) sym in/: string grid ./: {(2+x;3+x)} coord;
					:1b]]];
	
		if[(1 in ind) & not 7 in ind;
			if[yAxisUp & yAxis2Up;
				if[all (raze/) sym in/: string grid ./: @\[coord; 0; -; 2 1];
					:1b]]];

		if[all 1 7 in ind;
			if[yAxisUp or yAxisDown;
				if[any (raze/) sym in/: string grid ./: @\[coord; 0; -; 2 -4];
					:1b]]];
			
		if[(7 in ind) & not 1 in ind;
			if[yAxisDown & yAxis2Down;
				if[all (raze/) sym in/: string grid ./: @\[coord; 0; +; 2 1];
					:1b]]];
			
		if[(2 in ind) & not 6 in ind;
			if[yAxis2Up & xAxis2Right;
				if[all (raze/) sym in/: string grid ./: 2_{(-1+x 0; 1+x 1)}\[3;coord];
					:1b]]];
			
		if[all 2 6 in ind;
			if[(yAxisUp & xAxisRight) or (yAxisDown & xAxisLeft);
				if[any (raze/) sym in/: string grid ./: {x[;0],'reverse x[;1]} ({(x-2; x+2)}coord);
					:1b]]];
			
		if[(6 in ind) & not 2 in ind;
			if[yAxis2Down & xAxis2Left;
				if[all (raze/) sym in/: string grid ./: 2_{(1+x 0; -1+x 1)}\[3;coord];
					:1b]]];
			
		if[(3 in ind) & not 5 in ind;
			if[xAxisLeft & xAxis2Left;
				if[all (raze/) sym in/: string grid ./: @\[coord; 1; -; 2 1];
					:1b]]];
			
		if[all 3 5 in ind;
			if[xAxisLeft or xAxisRight;
				if[any (raze/) sym in/: string grid ./: @\[coord; 1; -; 2 -4];
					:1b]]];
			
		if[(5 in ind) & not 3 in ind;
			if[xAxisRight & xAxis2Right;
				if[all (raze/) sym in/: string grid ./: @\[coord; 1; +; 2 1];
					:1b]]];
					
		:0b

		};
		
		
	