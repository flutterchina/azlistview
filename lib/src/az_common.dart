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
