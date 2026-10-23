
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const AtlasApp());

const forest = Color(0xFF173D32);
const gold = Color(0xFFD6A85B);
const paper = Color(0xFFF7F6F1);
const muted = Color(0xFF777D77);

class AtlasApp extends StatefulWidget {
  const AtlasApp({super.key});

  @override
  State<AtlasApp> createState() => _AtlasAppState();
}

class _AtlasAppState extends State<AtlasApp> {
  bool dark = false;
  bool signedIn = false;
  String userName = 'Traveler';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ATLAS Travel Planner',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: dark ? const Color(0xFF151A17) : paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: forest,
          brightness: dark ? Brightness.dark : Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: dark ? const Color(0xFF242B27) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: signedIn
          ? AtlasHome(
              userName: userName,
              dark: dark,
              onTheme: () => setState(() => dark = !dark),
              onSignOut: () => setState(() => signedIn = false),
            )
          : WelcomePage(
              onEnter: (name) => setState(() {
                userName = name;
                signedIn = true;
              }),
            ),
    );
  }
}

class Destination {
  final String name;
  final String country;
  final String category;
  final String description;
  final String emoji;
  final int dailyCost;
  final double rating;
  final int days;
  final List<String> activities;

  const Destination({
    required this.name,
    required this.country,
    required this.category,
    required this.description,
    required this.emoji,
    required this.dailyCost,
    required this.rating,
    required this.days,
    required this.activities,
  });

  int estimate(int travellers, int tripDays) =>
      dailyCost * travellers * tripDays;
}

const places = <Destination>[
  Destination(
    name: 'Manali',
    country: 'Himachal Pradesh',
    category: 'Mountains',
    description: 'Pine forests, mountain roads and Himalayan views.',
    emoji: '🏔️',
    dailyCost: 2400,
    rating: 4.8,
    days: 4,
    activities: ['Solang Valley', 'Old Manali walk', 'Mountain café',
      'Rohtang-area sightseeing'],
  ),
  Destination(
    name: 'Goa',
    country: 'India',
    category: 'Beach',
    description: 'Sunsets, colourful streets and relaxed beach days.',
    emoji: '🏝️',
    dailyCost: 2800,
    rating: 4.7,
    days: 3,
    activities: ['Beach sunrise', 'Old Goa heritage walk',
      'Local food tour', 'Sunset by the sea'],
  ),
  Destination(
    name: 'Munnar',
    country: 'Kerala',
    category: 'Nature',
    description: 'Tea gardens, misty hills and quiet scenic drives.',
    emoji: '🌿',
    dailyCost: 2100,
    rating: 4.6,
    days: 3,
    activities: ['Tea garden visit', 'Scenic viewpoint',
      'Tea museum', 'Nature walk'],
  ),
  Destination(
    name: 'Jaipur',
    country: 'Rajasthan',
    category: 'Culture',
    description: 'Royal architecture, markets and local cuisine.',
    emoji: '🏰',
    dailyCost: 1900,
    rating: 4.7,
    days: 2,
    activities: ['Amber Fort', 'City Palace',
      'Hawa Mahal viewpoint', 'Local bazaar'],
  ),
  Destination(
    name: 'Rishikesh',
    country: 'Uttarakhand',
    category: 'Adventure',
    description: 'River views, yoga, trails and outdoor activities.',
    emoji: '🌊',
    dailyCost: 1800,
    rating: 4.5,
    days: 3,
    activities: ['Riverfront walk', 'Café by the Ganges',
      'Nature trail', 'Evening aarti'],
  ),
  Destination(
    name: 'Ooty',
    country: 'Tamil Nadu',
    category: 'Nature',
    description: 'Cool weather, gardens and winding hill roads.',
    emoji: '🚞',
    dailyCost: 2200,
    rating: 4.5,
    days: 3,
    activities: ['Botanical Garden', 'Tea factory',
      'Scenic train experience', 'Lake walk'],
  ),
];

String money(num n) {
  final value = n.round().toString();
  final formatted = value.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
  return '₹$formatted';
}

class WelcomePage extends StatefulWidget {
  final ValueChanged<String> onEnter;
  const WelcomePage({super.key, required this.onEnter});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool register = false;
  bool hidePassword = true;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void submit() {
    if (email.text.trim().isEmpty ||
        !email.text.contains('@') ||
        password.text.length < 4 ||
        (register && name.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid email, password and required details.'),
        ),
      );
      return;
    }
    widget.onEnter(
      register && name.text.trim().isNotEmpty
          ? name.text.trim()
          : email.text.split('@').first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 950),
            child: LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth > 650;
              final form = Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(register ? 'CREATE ACCOUNT' : 'WELCOME BACK',
                        style: const TextStyle(
                          color: gold,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 12),
                    Text(register ? 'Start exploring.' : 'Your next story awaits.',
                        style: const TextStyle(
                          fontSize: 29, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 24),
                    if (register) ...[
                      TextField(
                        controller: name,
                        decoration: const InputDecoration(
                          labelText: 'Your name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: password,
                      obscureText: hidePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => hidePassword = !hidePassword),
                          icon: Icon(hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: forest,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(17),
                        ),
                        onPressed: submit,
                        child: Text(register ? 'Create account' : 'Sign in'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () => setState(() => register = !register),
                        child: Text(register
                            ? 'Already have an account? Sign in'
                            : 'New to ATLAS? Create an account'),
                      ),
                    ),
                    const Text(
                      'Demo mode: details are not stored or authenticated.',
                      style: TextStyle(fontSize: 11, color: muted),
                    ),
                  ],
                ),
              );

              final intro = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.explore, color: gold, size: 40),
                  const SizedBox(height: 16),
                  const Text('ATLAS',
                      style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 5)),
                  const Text('TRAVEL, YOUR WAY',
                      style: TextStyle(
                          color: gold,
                          fontSize: 12,
                          letterSpacing: 3,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Text(
                    'Discover places, set your budget, and shape a trip that feels like yours.',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 17,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 25),
                  const _Perk(icon: Icons.wallet_outlined,
                      text: 'Plan around your own budget'),
                  const _Perk(icon: Icons.route_outlined,
                      text: 'Build a day-by-day itinerary'),
                  const _Perk(icon: Icons.favorite_border,
                      text: 'Save places you love'),
                ],
              );

              return wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: Padding(
                          padding: const EdgeInsets.all(28), child: intro)),
                        const SizedBox(width: 24),
                        Expanded(child: form),
                      ],
                    )
                  : Column(children: [
                      intro,
                      const SizedBox(height: 28),
                      form,
                    ]);
            }),
          ),
        ),
      ),
    );
  }
}

class _Perk extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Perk({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(children: [
          Icon(icon, color: gold),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ]),
      );
}

class AtlasHome extends StatefulWidget {
  final String userName;
  final bool dark;
  final VoidCallback onTheme;
  final VoidCallback onSignOut;

  const AtlasHome({
    super.key,
    required this.userName,
    required this.dark,
    required this.onTheme,
    required this.onSignOut,
  });

  @override
  State<AtlasHome> createState() => _AtlasHomeState();
}

class _AtlasHomeState extends State<AtlasHome> {
  int tab = 0;
  String query = '';
  String category = 'All';
  String sort = 'Recommended';
  bool savedOnly = false;
  bool withinBudgetOnly = false;
  final Set<String> favourites = {};
  final Set<String> completed = {};
  final List<String> customActivities = [];

  Destination selected = places.first;
  int tripDays = 3;
  int travellers = 2;

  double budget = 30000;
  double accommodation = 0.35;
  double transport = 0.25;
  double food = 0.20;
  double activities = 0.20;

  final budgetController = TextEditingController(text: '30000');
  final daysController = TextEditingController(text: '3');
  final peopleController = TextEditingController(text: '2');
  final customController = TextEditingController();

  @override
  void dispose() {
    budgetController.dispose();
    daysController.dispose();
    peopleController.dispose();
    customController.dispose();
    super.dispose();
  }

  int get estimate => selected.dailyCost * tripDays * travellers;
  int get remaining => budget.round() - estimate;

  void updateBudget(String value) {
    final n = int.tryParse(value.replaceAll(',', '').trim());
    if (n != null && n >= 0) setState(() => budget = n.toDouble());
  }

  void setBudgetFromSlider(double value) {
    setState(() {
      budget = value;
      budgetController.text = value.round().toString();
      budgetController.selection =
          TextSelection.collapsed(offset: budgetController.text.length);
    });
  }

  void notify(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void plan(Destination place) {
    setState(() {
      selected = place;
      tripDays = place.days;
      daysController.text = '$tripDays';
      tab = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final destinations = places.where((p) {
      final matchesQuery =
          '${p.name} ${p.country}'.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = category == 'All' || p.category == category;
      final matchesSaved = !savedOnly || favourites.contains(p.name);
      final matchesBudget = !withinBudgetOnly ||
          p.dailyCost * tripDays * travellers <= budget;
      return matchesQuery &&
          matchesCategory &&
          matchesSaved &&
          matchesBudget;
    }).toList();

    if (sort == 'Lowest cost') {
      destinations.sort((a, b) => a.dailyCost.compareTo(b.dailyCost));
    } else if (sort == 'Top rated') {
      destinations.sort((a, b) => b.rating.compareTo(a.rating));
    }

    final pages = [
      _buildExplore(destinations),
      _buildSaved(),
      _buildPlanner(),
      _buildBudget(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.explore, color: gold),
          SizedBox(width: 8),
          Text('ATLAS', style: TextStyle(
            fontWeight: FontWeight.w900, letterSpacing: 3)),
        ]),
        actions: [
          IconButton(
            tooltip: 'Switch theme',
            onPressed: widget.onTheme,
            icon: Icon(widget.dark ? Icons.light_mode : Icons.dark_mode),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PopupMenuButton<String>(
              tooltip: 'Account',
              onSelected: (v) {
                if (v == 'logout') widget.onSignOut();
                if (v == 'summary') showSummary();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'summary',
                    child: Text('Trip summary')),
                PopupMenuItem(value: 'logout',
                    child: Text('Sign out')),
              ],
              child: CircleAvatar(
                backgroundColor: forest,
                child: Text(
                  widget.userName.isNotEmpty
                      ? widget.userName[0].toUpperCase()
                      : 'T',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1250),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: pages[tab],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.explore_outlined), label: 'Explore'),
          NavigationDestination(
              icon: Icon(Icons.favorite_border), label: 'Saved'),
          NavigationDestination(
              icon: Icon(Icons.route_outlined), label: 'My trip'),
          NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'Budget'),
        ],
      ),
    );
  }

  Widget _buildExplore(List<Destination> destinations) {
    return ListView(
      children: [
        const Text('FIND YOUR NEXT ESCAPE',
            style: TextStyle(
                color: gold,
                fontWeight: FontWeight.bold,
                letterSpacing: 2)),
        const SizedBox(height: 10),
        const Text('Where to next?',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('Discover places that fit your travel style and budget.'),
        const SizedBox(height: 20),
        TextField(
          onChanged: (v) => setState(() => query = v),
          decoration: const InputDecoration(
            hintText: 'Search places or regions...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'All', 'Mountains', 'Beach', 'Nature', 'Culture', 'Adventure'
          ].map((c) => ChoiceChip(
            label: Text(c),
            selected: category == c,
            onSelected: (_) => setState(() => category = c),
          )).toList(),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Saved only'),
              selected: savedOnly,
              onSelected: (v) => setState(() => savedOnly = v),
            ),
            FilterChip(
              label: const Text('Within my budget'),
              selected: withinBudgetOnly,
              onSelected: (v) => setState(() => withinBudgetOnly = v),
            ),
            SizedBox(
              width: 165,
              child: DropdownButtonFormField<String>(
                value: sort,
                decoration: const InputDecoration(
                  labelText: 'Sort destinations',
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(value: 'Recommended',
                      child: Text('Recommended')),
                  DropdownMenuItem(value: 'Lowest cost',
                      child: Text('Lowest cost')),
                  DropdownMenuItem(value: 'Top rated',
                      child: Text('Top rated')),
                ],
                onChanged: (v) => setState(() => sort = v ?? sort),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('${destinations.length} destinations',
            style: const TextStyle(color: muted)),
        const SizedBox(height: 12),
        if (destinations.isEmpty)
          const Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: Text(
              'No matches. Try another category or budget.')),
          )
        else
          LayoutBuilder(builder: (context, constraints) {
            final columns = constraints.maxWidth > 900
                ? 3
                : constraints.maxWidth > 580
                    ? 2
                    : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: destinations.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                mainAxisExtent: 365,
              ),
              itemBuilder: (context, i) =>
                  _destinationCard(destinations[i]),
            );
          }),
      ],
    );
  }

  Widget _destinationCard(Destination place) {
    final isSaved = favourites.contains(place.name);
    final cost = place.dailyCost * tripDays * travellers;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [forest, Color(0xFF779B82)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Center(child: Text(place.emoji,
                    style: const TextStyle(fontSize: 65))),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton.filledTonal(
                    tooltip: isSaved ? 'Remove saved place' : 'Save place',
                    onPressed: () => setState(() {
                      isSaved
                          ? favourites.remove(place.name)
                          : favourites.add(place.name);
                    }),
                    icon: Icon(isSaved
                        ? Icons.favorite
                        : Icons.favorite_border),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 10,
                  child: Chip(
                    label: Text(place.category),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(place.name,
                        style: const TextStyle(
                            fontSize: 19, fontWeight: FontWeight.w800))),
                    const Icon(Icons.star, color: gold, size: 17),
                    Text(' ${place.rating}'),
                  ]),
                  Text(place.country,
                      style: const TextStyle(color: muted, fontSize: 12)),
                  const SizedBox(height: 7),
                  Text(place.description,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  Text('ESTIMATE FOR YOUR TRIP',
                      style: const TextStyle(
                          color: muted, fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                  Text(money(cost),
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: forest,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => plan(place),
                      child: const Text('Plan this trip'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaved() {
    final saved = places.where((p) => favourites.contains(p.name)).toList();

    return ListView(children: [
      const Text('YOUR COLLECTION',
          style: TextStyle(color: gold, letterSpacing: 2,
              fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Saved places',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
      const SizedBox(height: 18),
      if (saved.isEmpty)
        const _EmptyState(
          icon: Icons.favorite_border,
          title: 'Nothing saved yet',
          detail: 'Tap the heart on a destination to keep it here.',
        )
      else
        ...saved.map((p) => Card(
          child: ListTile(
            leading: Text(p.emoji,
                style: const TextStyle(fontSize: 30)),
            title: Text(p.name),
            subtitle: Text('${p.country} • ${money(p.dailyCost)}/person/day'),
           trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
              IconButton(
                tooltip: 'Plan trip',
                onPressed: () => plan(p),
                icon: const Icon(Icons.route),
              ),
              IconButton(
                tooltip: 'Remove',
                onPressed: () => setState(() => favourites.remove(p.name)),
                icon: const Icon(Icons.delete_outline),
              ),
            ]),
          ),
        )),
    ]);
  }

  Widget _buildPlanner() {
    final itinerary = [
      ...selected.activities.take(tripDays * 2),
      ...customActivities,
    ];

    return ListView(children: [
      const Text('YOUR JOURNEY',
          style: TextStyle(color: gold, letterSpacing: 2,
              fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(selected.name,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
      Text('${selected.country} • ${money(estimate)} estimated trip total',
          style: const TextStyle(color: muted)),
      const SizedBox(height: 20),
      _panel(
        title: 'Trip details',
        child: Column(children: [
          Row(children: [
            const Expanded(child: Text('Number of days')),
            IconButton(
              onPressed: tripDays > 1
                  ? () => setState(() {
                        tripDays--;
                        daysController.text = '$tripDays';
                      })
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            SizedBox(
              width: 52,
              child: TextField(
                controller: daysController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) {
                  final n = int.tryParse(v);
                  if (n != null && n >= 1 && n <= 30) {
                    setState(() => tripDays = n);
                  }
                },
              ),
            ),
            IconButton(
              onPressed: tripDays < 30
                  ? () => setState(() {
                        tripDays++;
                        daysController.text = '$tripDays';
                      })
                  : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ]),
          Row(children: [
            const Expanded(child: Text('Travellers')),
            IconButton(
              onPressed: travellers > 1
                  ? () => setState(() {
                        travellers--;
                        peopleController.text = '$travellers';
                      })
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            SizedBox(
              width: 52,
              child: TextField(
                controller: peopleController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) {
                  final n = int.tryParse(v);
                  if (n != null && n >= 1 && n <= 20) {
                    setState(() => travellers = n);
                  }
                },
              ),
            ),
            IconButton(
              onPressed: travellers < 20
                  ? () => setState(() {
                        travellers++;
                        peopleController.text = '$travellers';
                      })
                  : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ]),
          const Divider(),
          _stat('Estimated total', money(estimate)),
          _stat('Budget remaining', money(remaining),
              color: remaining < 0 ? Colors.red : forest),
          _stat('Per person', money(estimate / travellers)),
          _stat('Per day, group', money(estimate / tripDays)),
          if (remaining < 0)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('This plan is above your budget. Adjust your trip or budget.',
                  style: TextStyle(color: Colors.red)),
            ),
        ]),
      ),
      const SizedBox(height: 16),
      _panel(
        title: 'Day-by-day itinerary',
        trailing: Text('${completed.length}/${itinerary.length} done',
            style: const TextStyle(color: muted)),
        child: Column(children: [
          for (int day = 0; day < tripDays; day++) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Text('DAY ${day + 1}',
                    style: const TextStyle(
                        color: gold, fontWeight: FontWeight.w900,
                        letterSpacing: 1.4)),
              ),
            ),
            for (int j = day * 2;
                j < (day * 2 + 2) && j < selected.activities.length;
                j++)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: completed.contains('${selected.name}-$j'),
                onChanged: (v) => setState(() {
                  v == true
                      ? completed.add('${selected.name}-$j')
                      : completed.remove('${selected.name}-$j');
                }),
                title: Text(selected.activities[j]),
                subtitle: Text(j.isEven ? 'Morning / afternoon' : 'Afternoon / evening'),
              ),
          ],
          const Divider(),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('CUSTOM ACTIVITIES',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: TextField(
                controller: customController,
                decoration: const InputDecoration(
                  hintText: 'Add your own activity',
                ),
                onSubmitted: (_) => addActivity(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: addActivity,
              icon: const Icon(Icons.add),
            ),
          ]),
          for (int i = 0; i < customActivities.length; i++)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: completed.contains('custom-$i'),
              onChanged: (v) => setState(() {
                v == true
                    ? completed.add('custom-$i')
                    : completed.remove('custom-$i');
              }),
              title: Text(customActivities[i]),
              secondary: IconButton(
                onPressed: () => setState(() {
                  customActivities.removeAt(i);
                  completed.remove('custom-$i');
                }),
                icon: const Icon(Icons.close),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: showSummary,
        icon: const Icon(Icons.ios_share),
        label: const Text('View and share trip summary'),
      ),
    ]);
  }

  void addActivity() {
    final text = customController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      customActivities.add(text);
      customController.clear();
    });
    notify('Activity added to your itinerary.');
  }

  Widget _buildBudget() {
    final cost = estimate.toDouble();
    final allocation = [
      ('Accommodation', accommodation, Icons.hotel_outlined),
      ('Transport', transport, Icons.directions_car_outlined),
      ('Food', food, Icons.restaurant_outlined),
      ('Activities', activities, Icons.local_activity_outlined),
    ];

    return ListView(children: [
      const Text('YOUR MONEY, YOUR RULES',
          style: TextStyle(color: gold, letterSpacing: 2,
              fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Trip budget',
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      const Text('Enter a budget or move the slider. Estimates update instantly.'),
      const SizedBox(height: 20),
      _panel(
        title: 'Set your spending limit',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Total budget in Indian rupees',
                prefixText: '₹ ',
                helperText: 'Example: 30000',
              ),
              onChanged: updateBudget,
            ),
            const SizedBox(height: 14),
            Row(children: [
              const Text('₹5,000'),
              Expanded(
                child: Slider(
                  value: budget.clamp(5000, 250000),
                  min: 5000,
                  max: 250000,
                  divisions: 49,
                  activeColor: forest,
                  label: money(budget),
                  onChanged: setBudgetFromSlider,
                ),
              ),
              const Text('₹2.5L'),
            ]),
            Wrap(
              spacing: 8,
              children: [10000, 20000, 30000, 50000, 100000].map((v) =>
                ActionChip(
                  label: Text(money(v)),
                  onPressed: () {
                    setState(() {
                      budget = v.toDouble();
                      budgetController.text = '$v';
                    });
                  },
                )).toList(),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: forest,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('YOUR CURRENT TRIP ESTIMATE',
                      style: TextStyle(
                          color: Colors.white70, letterSpacing: 1.2,
                          fontSize: 10)),
                  const SizedBox(height: 8),
                  Text(money(cost),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900)),
                  Text('${selected.name} • $tripDays days • $travellers travellers',
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 14),
                  LinearProgressIndicator(
                    value: budget <= 0
                        ? 1
                        : (cost / budget).clamp(0, 1).toDouble(),
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    color: cost > budget ? Colors.redAccent : gold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    budget <= 0
                        ? 'Enter a budget greater than zero to compare.'
                        : remaining >= 0
                            ? '${money(remaining)} remaining'
                            : '${money(-remaining)} over budget',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _panel(
        title: 'Allocate your budget',
        trailing: Text('${(accommodation + transport + food + activities) * 100 ~/ 1}%'),
        child: Column(children: [
          for (final item in allocation) ...[
            Row(children: [
              Icon(item.$3, color: gold),
              const SizedBox(width: 8),
              Expanded(child: Text(item.$1)),
              Text('${(item.$2 * 100).round()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text(money(budget * item.$2)),
            ]),
            Slider(
              value: item.$2,
              min: 0,
              max: 1,
              activeColor: forest,
              onChanged: (v) => setState(() {
                switch (item.$1) {
                  case 'Accommodation': accommodation = v;
                  case 'Transport': transport = v;
                  case 'Food': food = v;
                  case 'Activities': activities = v;
                }
              }),
            ),
          ],
          const Divider(),
          _stat('Total allocated', '${((accommodation + transport + food + activities) * 100).round()}%'),
          if ((accommodation + transport + food + activities - 1).abs() > 0.001)
            const Text('Tip: adjust the sliders until your allocation totals 100%.',
                style: TextStyle(color: muted)),
          const SizedBox(height: 8),
          for (final item in allocation)
            _stat(item.$1, money(budget * item.$2)),
          TextButton.icon(
            onPressed: () => setState(() {
              accommodation = .35;
              transport = .25;
              food = .20;
              activities = .20;
            }),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset allocation'),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      _panel(
        title: 'Budget tips',
        child: Column(children: [
          _tip('Choose quieter dates',
              'Flexible dates can reduce transport and stay costs.'),
          _tip('Set your group size',
              'Per-person costs help you compare trips fairly.'),
          _tip('Keep a buffer',
              'Reserve 10% for unexpected expenses.'),
        ]),
      ),
    ]);
  }

  Widget _tip(String title, String description) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.lightbulb_outline, color: gold),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text(description),
  );

  Widget _panel({
    required String title,
    required Widget child,
    Widget? trailing,
  }) => Card(
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800))),
            if (trailing != null) trailing,
          ]),
          const SizedBox(height: 14),
          child,
        ],
      ),
    ),
  );

  Widget _stat(String label, String value, {Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Expanded(child: Text(label)),
      Text(value, style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800)),
    ]),
  );

  void showSummary() {
    final text = '''
ATLAS TRIP SUMMARY
------------------
Destination: ${selected.name}, ${selected.country}
Duration: $tripDays days
Travellers: $travellers
Estimated trip cost: ${money(estimate)}
Total budget: ${money(budget)}
Remaining: ${money(remaining)}
Activities completed: ${completed.length}
Saved destinations: ${favourites.length}

Estimates are illustrative, not live travel quotes.
''';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Your trip summary'),
        content: SingleChildScrollView(child: SelectableText(text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              Navigator.pop(dialogContext);
              notify('Trip summary copied. You can paste and share it.');
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy summary'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(35),
    child: Column(children: [
      Icon(icon, size: 45, color: gold),
      const SizedBox(height: 12),
      Text(title, style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text(detail, textAlign: TextAlign.center,
          style: const TextStyle(color: muted)),
    ]),
  );
}
