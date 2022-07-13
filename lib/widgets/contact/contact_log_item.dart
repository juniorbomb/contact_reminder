import 'package:auto_size_text/auto_size_text.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../configs/colors.dart';
import '../../configs/dimensions.dart';
import '../../models/contact_log_model.dart';
import '../../models/log_type.dart';

class ContactLogItem extends StatefulWidget {
  const ContactLogItem({
    Key? key,
    required this.entry,
  }) : super(key: key);

  final ContactLogModel entry;

  @override
  State<ContactLogItem> createState() => _ContactLogItemState();
}

class _ContactLogItemState extends State<ContactLogItem> {
  bool _isExpanded = false;

  toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: toggle,
      leading: Container(
        height: 40,
        width: 40,
        alignment: Alignment.center,
        child: Icon(
          widget.entry.type == Type.call ? Icons.call : Icons.message,
          color: ColorPallet.secondaryColor,
        ),
      ),
      title: AutoSizeText(
        widget.entry.name,
        style: const TextStyle(
          fontSize: Dimensions.FONT_SIZE_LARGE,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              widget.entry.type == Type.call
                  ? widget.entry.number
                  : "Message: " + widget.entry.message,
              maxLines: _isExpanded ? null : 1,
              overflow: _isExpanded ? null : TextOverflow.ellipsis,
              style: TextStyle(
                color: ColorPallet.blackColor.withOpacity(0.6),
              ),
            ),
          ),
          if (widget.entry.type == Type.call) ...[
            const SizedBox(width: 6),
            Icon(
              widget.entry.callType == CallType.incoming
                  ? Icons.phone_callback
                  : widget.entry.callType == CallType.outgoing
                      ? Icons.phone_forwarded
                      : Icons.phone,
              color: ColorPallet.blackColor.withOpacity(0.6),
              size: 12,
            ),
          ],
        ],
      ),
      trailing: AutoSizeText(
        DateFormat("d MMM hh:mm a").format(widget.entry.dateTime),
        style: TextStyle(
          color: ColorPallet.blackColor.withOpacity(0.5),
        ),
      ),
    );
  }
}
