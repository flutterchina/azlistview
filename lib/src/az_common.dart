import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naslovnik/bloc/contacts_cubit.dart';
import 'package:naslovnik/bloc/contacts_states.dart';
import 'package:naslovnik/bloc/login_cubit.dart';
import 'package:naslovnik/bloc/login_states.dart';
import 'package:naslovnik/helpers/debouncer.dart';
import 'package:naslovnik/models/contact.dart';
import 'package:naslovnik/screens/auth/login_screen.dart';
import 'package:naslovnik/screens/settings_screen.dart';
import 'package:naslovnik/screens/widgets/avatar_with_initials.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController controller = TextEditingController();

  List<Contact> contacts = [];

  List<String> alphabet = List.generate(
      26, (index) => String.fromCharCode('A'.codeUnitAt(0) + index));

  int index = 0;

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      setState(() {});
    });
    context.read<ContactsCubit>().fetchContacts();
  }

  @override
  Widget build(BuildContext context) {
    final contactsCubit = context.read<ContactsCubit>();
    final filterParams = contactsCubit.state.filterParams;

    final excludedKeys = ['q', 'o'];

    int activeFilterCount = filterParams != null
        ? filterParams.keys
            .where((key) =>
                !excludedKeys.contains(key) && filterParams[key] != null)
            .length
        : 0;

    final _debouncer = Debouncer(milliseconds: 800);
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              state.message!,
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green,
            elevation: 30.0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ));
        }
      },
      builder: (context, state) {
        if (state is LoginSuccessState) {
          return Scaffold(
            appBar: AppBar(
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                title: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // Use MainAxisAlignment.spaceBetween
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.black87,
                        radius: 18,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundImage: AssetImage('assets/logo/1024.png'),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          onChanged: (query) {
                            final q = (query.isNotEmpty) ? query : null;
                            _debouncer.run(() {
                              contactsCubit.updateFilterParam('q', q);
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            contentPadding: const EdgeInsets.all(0),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade500,
                            ),
                            suffixIcon: (controller.text.isNotEmpty)
                                ? IconButton(
                                    splashRadius: 20,
                                    onPressed: () {
                                      controller.clear();
                                      contactsCubit.updateFilterParam(
                                          'q', null);
                                    },
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors
                                          .black, // Customize the icon color
                                    ),
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide.none,
                            ),
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            hintText: (filterParams?['o'] == 'osebe')
                                ? 'Iskanje posvečenih oseb'
                                : 'Iskanje župnij, ustanov,...',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      IconButton(
                        splashRadius: 20,
                        onPressed: () {
                          showFilterBottomSheet(context);
                        },
                        icon: (activeFilterCount > 0)
                            ? Badge(
                                label: Text(activeFilterCount.toString()),
                                child: const Icon(
                                  Icons.filter_alt_outlined,
                                  color:
                                      Colors.black, // Customize the icon color
                                ),
                              )
                            : const Icon(
                                Icons.filter_alt_outlined,
                                color: Colors.black, // Customize the icon color
                              ),
                      ),
                    ],
                  ),
                )),
            body: BlocBuilder<ContactsCubit, ContactsState>(
              builder: (BuildContext context, ContactsState contactsState) {
                if (contactsState is ContactsLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (contactsState is ContactsLoadedState) {
                  _handleList(contactsState.contacts);
                  final contacts = contactsState.contacts;
                  return RefreshIndicator(
                    onRefresh: () async {
                      contactsCubit.fetchContacts();
                    },
                    child: AzListView(
                      hapticFeedback: true,
                      data: contacts,
                      itemCount: contacts.length,
                      indexBarOptions: const IndexBarOptions(
                        needRebuild: true,
                        indexHintAlignment: Alignment.centerRight,
                        indexHintOffset: Offset(-20, 0),
                        selectItemDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        // if (index == 0) return _buildHeader();
                        final contact = contacts[index];
                        return contactComponent(contact: contact);
                      },
                    ),
                  );
                } else if (contactsState is ContactsErrorState) {
                  return Center(child: Text(contactsState.errorMessage));
                } else {
                  return Container(); // You can provide a default state if needed.
                }
              },
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (index) => setState(() {
                this.index = index;

                if (index == 0) {
                  contactsCubit.updateFilterParam('o', 'ustanove');
                }

                if (index == 1) {
                  contactsCubit.updateFilterParam('o', 'osebe');
                }

                if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()),
                  );
                }
                ;
              }),
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.church_outlined),
                    label: 'Župnije/ustanove'),
                NavigationDestination(
                    icon: Icon(Icons.people_alt_outlined),
                    label: 'Posvečene osebe'),
                NavigationDestination(
                    icon: Icon(Icons.settings_outlined), label: 'Nastavitve'),
              ],
            ),
          );
        } else {
          return MaterialApp(
            home: LoginScreen(),
          );
        }
      },
    );
  }

  contactComponent({required Contact contact}) {
    String susTag = contact.getSuspensionTag();
    return Column(
      children: [
        Offstage(
          offstage: contact.isShowSuspension != true,
          child: _buildSusWidget(susTag),
        ),
        Container(
          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 16.0),
          child: Row(
            children: [
              SizedBox(
                height: 38,
                width: 38,
                child: AvatarWithInitials(
                  name: contact.avatar,
                  fontSize: 16.0,
                  radius: 18,
                ),
              ),
              const SizedBox(
                width: 10.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 16.0),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (contact.parent != null)
                      Text(contact.parent!,
                          style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _buildSusWidget(String susTag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      height: 30,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Text(
            '$susTag',
            textScaleFactor: 1.2,
          ),
          const Expanded(
              child: Divider(
            height: .0,
            indent: 10.0,
          ))
        ],
      ),
    );
  }

  void showFilterBottomSheet(BuildContext context) {
    final contactsCubit = context.read<ContactsCubit>();
    final filterParams = contactsCubit.state.filterParams;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
      builder: (context) {
        return Scrollbar(
          thickness: 3, //width of scrollbar
          radius: Radius.circular(10), //corner radius of scrollbar
          scrollbarOrientation: ScrollbarOrientation.right,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Filtriranje',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20.0),
                  const Text(
                    'Tip entitete',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10.0),
                  Wrap(spacing: 12.0, children: [
                    FilterChip(
                        label: const Text('Župnija'), onSelected: (val) => {}),
                    FilterChip(
                        label: const Text('Dekanija'), onSelected: (val) => {}),
                    FilterChip(
                        label: const Text('Škofija'), onSelected: (val) => {}),
                    FilterChip(
                        label: const Text('Skupnost'), onSelected: (val) => {}),
                  ]),
                  SizedBox(height: 10.0),
                  const Text(
                    'Škofije',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                  ),
                  Wrap(spacing: 12.0, children: [
                    FilterChip(
                        label: const Text('Škofija Koper'),
                        onSelected: (val) => {}),
                    FilterChip(
                        label: const Text('Nadškofija Ljubljana'),
                        onSelected: (val) => {}),
                    FilterChip(
                        label: const Text('Škofija Novo mesto'),
                        onSelected: (val) => {}),
                    FilterChip(
                        label: const Text('Škofija Celje'),
                        onSelected: (val) => {}),
                    FilterChip(
                        label: const Text('Nadškofija Maribor'),
                        onSelected: (val) => {}),
                    FilterChip(
                      label: const Text('Škofija Murska sobota'),
                      selectedColor: Colors.lightBlue,
                      onSelected: (val) => {},
                    ),
                  ]),
                  SizedBox(height: 10.0),
                  const Text(
                    'Dekanije',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                  ),
                  Wrap(spacing: 12.0, children: [
                    FilterChip(
                        label: const Text('Škofija Koper'),
                        onSelected: (val) =>
                            {contactsCubit.updateFilterParam('skofija', 2)}),
                    FilterChip(
                        label: const Text('Nadškofija Ljubljana'),
                        onSelected: (val) => {}),
                    FilterChip(
                        label: const Text('Škofija Novo mesto'),
                        onSelected: (val) => {}),
                    FilterChip(
                        label: const Text('Škofija Celje'),
                        onSelected: (val) => {}),
                    FilterChip(
                        label: const Text('Nadškofija Maribor'),
                        onSelected: (val) => {}),
                    FilterChip(
                        label: const Text('Škofija Murska sobota'),
                        onSelected: (val) => {}),
                  ]),
                  Wrap(spacing: 12.0, children: [
                    FilterChip(
                        label: const Text('Škofija Koper'),
                        onSelected: (val) => {}),
                    FilterChip(
                        label: const Text('Nadškofija Ljubljana'),
                        onSelected: (val) => {}),
                    FilterChip(
                        label: const Text('Škofija Novo mesto'),
                        onSelected: (val) => {}),
                    FilterChip(
                        label: const Text('Škofija Celje'),
                        onSelected: (val) => {}),
                    FilterChip(
                        label: const Text('Nadškofija Maribor'),
                        onSelected: (val) => {}),
                    FilterChip(
                        label: const Text('Škofija Murska sobota'),
                        onSelected: (val) => {}),
                  ]),
                  // Add your filter widgets here
                  // For example: Filter options, checkboxes, sliders, etc.
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleList(List<Contact> list) {
    if (list.isEmpty) return;

    for (int i = 0, length = list.length; i < length; i++) {
      String tag = list[i].avatar!.substring(0, 1).toUpperCase();
      String extendedTag = _getExtendedTag(tag);

      list[i].tagIndex = extendedTag;
    }

    // Sort the list based on the custom order
    list.sort((a, b) {
      final aTag = a.tagIndex ?? "";
      final bTag = b.tagIndex ?? "";
      return _customCompare(aTag, bTag);
    });

    SuspensionUtil.setShowSuspensionStatus(list);

  }

  String _getExtendedTag(String tag) {
    switch (tag) {
      case "Č":
        return "CČ"; // Map "Č" to come after "C"
      case "Š":
        return "SŠ"; // Map "Š" to come after "S"
      case "Ž":
        return "ZŽ"; // Map "Ž" to come after "Z"
      default:
        if (RegExp("[A-Z]").hasMatch(tag)) {
          return tag;
        } else {
          return "#";
        }
    }
  }

  int _customCompare(String a, String b) {
    if (a == b) return 0;
    if (a.startsWith("C") && b.startsWith("Č")) return -1;
    if (a.startsWith("Č") && b.startsWith("C")) return 1;
    if (a.startsWith("S") && b.startsWith("Š")) return -1;
    if (a.startsWith("Š") && b.startsWith("S")) return 1;
    if (a.startsWith("Z") && b.startsWith("Ž")) return -1;
    if (a.startsWith("Ž") && b.startsWith("Z")) return 1;
    return a.compareTo(b);
  }
}
