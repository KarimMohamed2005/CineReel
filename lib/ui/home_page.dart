import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_movies/bloc/movie_bloc.dart';
import 'package:flutter_bloc_movies/bloc/movie_provider.dart';
import 'package:flutter_bloc_movies/common_widgets/CommonWidgets.dart';
import 'package:flutter_bloc_movies/models/Movie.dart';
import 'package:flutter_bloc_movies/ui/movie_row.dart';

class HomePage extends StatefulWidget {
	const HomePage({Key key}) : super(key: key);

	@override
	_MyTabbedPageState createState() => new _MyTabbedPageState();
}

// ignore: mixin_inherits_from_not_object
class _MyTabbedPageState extends State<HomePage> with SingleTickerProviderStateMixin {
	// ignore: mixin_inherits_from_not_object
	final List<Tab> myTabs = <Tab>[
		new Tab(text: 'Now Playing'),
		new Tab(text: 'Top Rated'),
	];

	TabController _tabController;
	var _selectedTab;

	@override
	void initState() {
		super.initState();
		_tabController = new TabController(vsync: this, length: myTabs.length);
		_tabController.addListener(_handleTabSelection);
	}

	void _handleTabSelection() {
		if (_tabController.indexIsChanging) {
			return;
		}
		_selectedTab = _tabController.index;
		print("Changed tab to: ${_selectedTab.toString()}");
	}

	@override
	void dispose() {
		_tabController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return new Scaffold(
			appBar: buildAppBar(context, "flutter Bloc!", myTabs, _tabController),
			body: TabBarView(controller: _tabController, children: [
				Column(children: [Flexible(child: buildStreamList(0))]),
				Column(children: [Flexible(child: buildStreamList(1))]),
			]),
		);
	}

	StreamBuilder<List<Movie>> buildStreamList(int tabIndex) {
		final movieBloc = MovieProvider.of(context);

		return StreamBuilder(
			stream: movieBloc.getStreamForTab(tabIndex),
			initialData: movieBloc.getPageData(tabIndex),
			builder: (context, snapshot) {
				if (snapshot.hasError) {
					return buildErrorWidget(snapshot.error);
				}
				if (!snapshot.hasData) {
					return buildLoadingWidget();
				}
				return Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
				  mainAxisAlignment: MainAxisAlignment.start,
				  children: <Widget>[
						FlatButton.icon(onPressed: () => onDownloadTap(movieBloc), icon:
						Icon
							(Icons.pages),label: Text("Next page")),
						Expanded(child: buildListView(snapshot, movieBloc, tabIndex)),
				  ],
				);
			},
		);
	}

	Widget buildListView(AsyncSnapshot<List<Movie>> snapshot, MovieBloc
	movieBloc, int tabIndex) {
		return ListView.builder(
				itemCount: snapshot.data.length,
				itemBuilder: (context, index) {
					print("$index of ${snapshot.data.length}");
					if (index == snapshot.data.length - 2) {
						print('approaching end of list');
//          	movieBloc.nextPage.add(tabIndex);
					}
					return MovieRow(snapshot.data[index]);
				});
	}

	onDownloadTap(MovieBloc movieBloc) {
		print('get next page');
		movieBloc.getPageData(0);
	}
}
