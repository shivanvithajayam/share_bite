import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NgoReviewsScreen extends StatelessWidget {
  final String ngoId;

  const NgoReviewsScreen({super.key, required this.ngoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(ngoId)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("NGO Reviews");
            }

            final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

            return Text("${data['name'] ?? 'NGO'} Reviews");
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .where('targetId', isEqualTo: ngoId)
            .where('targetRole', isEqualTo: 'ngo')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reviews = snapshot.data!.docs;

          if (reviews.isEmpty) {
            return const Center(
              child: Text("No reviews yet", style: TextStyle(fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index].data() as Map<String, dynamic>;

              final rating = ((review['rating'] ?? 0) as num).toInt();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['donorName'] ?? 'Donor',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        review['review'] ?? '',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
