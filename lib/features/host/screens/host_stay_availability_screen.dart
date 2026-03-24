// lib/features/host/screens/host_stay_availability_screen.dart
// ✅ FIXED - Manages stay availability calendar

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:yaloo/features/host/providers/host_provider.dart';

class HostStayAvailabilityScreen extends StatefulWidget {
  final String stayId;

  const HostStayAvailabilityScreen({
    super.key,
    required this.stayId,
  });

  @override
  State<HostStayAvailabilityScreen> createState() => _HostStayAvailabilityScreenState();
}

class _HostStayAvailabilityScreenState extends State<HostStayAvailabilityScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isSaving = false;

  // Selected date range
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    // Load availability would go here if needed
  }

  Future<void> _saveAvailability() async {
    if (_rangeStart == null || _rangeEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date range')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final provider = context.read<HostProvider>();
    final success = await provider.setStayAvailability(widget.stayId, {
      'start_date': _rangeStart!.toIso8601String().split('T')[0],
      'end_date': _rangeEnd!.toIso8601String().split('T')[0],
      'total_room': 1, // You can make this dynamic
      'is_available': true,
    });

    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Availability updated! ✓'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        setState(() {
          _rangeStart = null;
          _rangeEnd = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${provider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Manage Availability',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveAvailability,
            child: _isSaving
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
            )
                : const Text(
              'Save',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              rangeSelectionMode: RangeSelectionMode.toggledOn,
              onRangeSelected: (start, end, focusedDay) {
                setState(() {
                  _rangeStart = start;
                  _rangeEnd = end;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
          const SizedBox(height: 16),
          if (_rangeStart != null && _rangeEnd != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Selected Range',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_rangeStart!.toLocal().toString().split(' ')[0]} - ${_rangeEnd!.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
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
}