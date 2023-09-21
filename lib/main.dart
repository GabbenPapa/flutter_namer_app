//import 'dart:html';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
	runApp(MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return ChangeNotifierProvider(
			create: (context) => MyAppState(),
			child: MaterialApp(
				title: 'Namer App',
				theme: ThemeData(
					useMaterial3: true,
					colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 3, 250, 238)),
				),
				home: MyHomePage(),
			),
		);
	}
}

class MyAppState extends ChangeNotifier {
	var current = WordPair.random();
	var history = <WordPair>[];
	var favorites = <WordPair>[];

	void getNext() {
		history.insert(0, current);
		current = WordPair.random();
		notifyListeners();
	}

	void toggleFavorite() {
		if (favorites.contains(current)) {
			favorites.remove(current);
		} else {
			favorites.add(current);
		}
		notifyListeners();
	}

	void removeFavorite(WordPair pair){
		favorites.remove(pair);
		notifyListeners();
	}

	void removeAllFavorite(){
		favorites = [];
		notifyListeners();
	}

	void removeHistory(WordPair pair){
		history.remove(pair);
		notifyListeners();
	}

	void removeAllHistory(){
		history = [];
		notifyListeners();
	}

}

class MyHomePage extends StatefulWidget {
	@override
	State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
	var selectedIndex = 0;

	@override
	Widget build(BuildContext context) {
		Widget page = Placeholder();
		switch (selectedIndex) {
			case 0:
				page = GeneratorPage();
				break;
			case 1:
				page = FavoritesPage();
				break;
			case 2:
				page = HistoryList();
				break;
		}
		return Scaffold(
			body: Row(
				children: [
					SafeArea(
						child: NavigationRail(
							extended: false,
							destinations: [
								NavigationRailDestination(
									icon: Icon(Icons.home),
									label: Text('Home'),
								),
								NavigationRailDestination(
									icon: Icon(Icons.favorite),
									label: Text('Favorites'),
								),
								NavigationRailDestination(
									icon: Icon(Icons.history),
									label: Text('History'),
								),
							],
							selectedIndex: selectedIndex,
							onDestinationSelected: (value) {
								setState(() {
									selectedIndex = value;
								});
							},
						),
					),
					Expanded(
						child: Container(
							color: Theme.of(context).colorScheme.primaryContainer,
							child: page,
						),
					),
				],
			),
		);
	}
}

class GeneratorPage extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		var appState = context.watch<MyAppState>();
		var pair = appState.current;

		IconData icon;
		if (appState.favorites.contains(pair)) {
			icon = Icons.favorite;
		} else {
			icon = Icons.favorite_border;
		}

		return Center(
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					BigCard(pair: pair),
					SizedBox(height: 10),
					Row(
						mainAxisSize: MainAxisSize.min,
						children: [
							ElevatedButton.icon(
								onPressed: () {
									appState.toggleFavorite();
								},
								icon: Icon(icon),
								label: Text('Like'),
							),
							SizedBox(width: 10),
							ElevatedButton(
								onPressed: () {
									appState.getNext();
								},
								child: Text('Next'),
							),
						],
					),
				],
			),
		);
	}
}

class BigCard extends StatelessWidget {
	const BigCard({
		Key? key,
		required this.pair,
	}) : super(key: key);

	final WordPair pair;

	@override
	Widget build(BuildContext context) {
		var theme = Theme.of(context);
		var style = theme.textTheme.displayMedium!.copyWith( 
			color: theme.colorScheme.onPrimary,
		);

		return Card(
			color: theme.colorScheme.primary,
			child: Padding(
				padding: const EdgeInsets.all(20.0),
				child: MergeSemantics(
					child: Wrap(
						children: [
							Text(
								pair.first,
								style: style.copyWith(fontWeight: FontWeight.w200),
							),
							Text(
								pair.second,
								style: style.copyWith(fontWeight: FontWeight.bold),
							)
						],
					),
				),
			),
		);
	}
}

class FavoritesPage extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		var theme = Theme.of(context);
		var appState = context.watch<MyAppState>();

		if (appState.favorites.isEmpty) {
			return Center(
				child: Text('No favorites yet.'),
			);
		}

		return Scaffold(
			backgroundColor: theme.colorScheme.primaryContainer, // Set background color to primaryContainer
			body:	ListView(
				children: [
					Padding(
						padding: const EdgeInsets.all(20),
						child: Text('You have ${appState.favorites.length} favorites:'),
					),
					for (var pair in appState.favorites)
						ListTile(
							leading: IconButton(
								icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
								color: theme.colorScheme.primary,
								onPressed: () {
									appState.removeFavorite(pair);
								},
							),
							title: Text(pair.asLowerCase),
						),
				],
				
			),
			floatingActionButton: FloatingActionButton(
				onPressed: () {
					appState.removeAllFavorite();
				},
				backgroundColor: Colors.white,
				child: Icon(Icons.delete),
			),
		);
	}
}

class HistoryList extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		var theme = Theme.of(context);
		var appState = context.watch<MyAppState>();

		if (appState.history.isEmpty) {
			return Center(
				child: Text('No history yet.'),
			);
		}

		return Scaffold(
			backgroundColor: theme.colorScheme.primaryContainer, // Set background color to primaryContainer
		
			body: ListView(
				children: [
					Padding(
						padding: const EdgeInsets.all(20),
						child: Text('You have ${appState.history.length} history items:'),
					),
					for (var pair in appState.history)
						ListTile(
							leading: IconButton(
								icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
								color: theme.colorScheme.primary,
								onPressed: () {
									appState.removeHistory(pair);
								},
							),
							title: Text(pair.asLowerCase),
						),
				],
				
			),
			floatingActionButton: FloatingActionButton(
				onPressed: () {
					appState.removeAllHistory();
				},
				backgroundColor: Colors.white,
				child: Icon(Icons.delete),
			),
		);
	}
}
