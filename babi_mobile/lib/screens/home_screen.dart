import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'products_list_screen.dart';
import 'add_product_screen.dart';
import 'suppliers_list_screen.dart';
import 'supplier_form_screen.dart';
import 'inventory_list_screen.dart';
import 'inventory_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    final accentColor = Colors.indigo.shade600;

    // Responsive width like LoginScreen
    final maxWidth = MediaQuery.of(context).size.width > 600
        ? 520.0
        : MediaQuery.of(context).size.width * 0.94;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: "Logout",
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                auth.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Welcome Card
                  Card(
                    elevation: 4, // subtle shadow like LoginScreen
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: accentColor.withOpacity(0.15),
                            child: Icon(Icons.person,
                                size: 42, color: accentColor),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Welcome Back",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                          ),
                          Text(
                            auth.user?['email'] ?? "User",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Section: Products
                  _buildSectionTitle("Products"),
                  _buildDashboardButton(
                    context,
                    label: "View Products",
                    icon: Icons.list,
                    color: Colors.white,
                    onTap: () => Navigator.of(context)
                        .pushNamed(ProductsListScreen.routeName),
                  ),
                  _buildDashboardButton(
                    context,
                    label: "Add Product",
                    icon: Icons.add,
                    color: Colors.white,
                    onTap: () => Navigator.of(context)
                        .pushNamed(AddProductScreen.routeName),
                  ),
                  const SizedBox(height: 20),

                  // Section: Suppliers
                  _buildSectionTitle("Suppliers"),
                  _buildDashboardButton(
                    context,
                    label: "View Suppliers",
                    icon: Icons.people,
                    color: Colors.white,
                    onTap: () => Navigator.of(context)
                        .pushNamed(SuppliersListScreen.routeName),
                  ),
                  _buildDashboardButton(
                    context,
                    label: "Add Supplier",
                    icon: Icons.person_add,
                    color: Colors.white,
                    onTap: () => Navigator.of(context)
                        .pushNamed(SupplierFormScreen.routeName),
                  ),
                  const SizedBox(height: 20),

                  // Section: Inventories
                  _buildSectionTitle("Inventories"),
                  _buildDashboardButton(
                    context,
                    label: "View Inventories",
                    icon: Icons.inventory,
                    color: Colors.white,
                    onTap: () => Navigator.of(context)
                        .pushNamed(InventoryListScreen.routeName),
                  ),
                  _buildDashboardButton(
                    context,
                    label: "Add Inventory",
                    icon: Icons.add_box,
                    color: Colors.white,
                    onTap: () => Navigator.of(context)
                        .pushNamed(InventoryFormScreen.routeName),
                  ),

                  const SizedBox(height: 20),
                  // Footer like LoginScreen
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Powered by',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 6),
                      Text('Babi Supply Chain',
                          style: TextStyle(
                              color: accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // Dashboard Button Widget
  Widget _buildDashboardButton(BuildContext context,
      {required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 22, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: onTap,
      ),
    );
  }
}
