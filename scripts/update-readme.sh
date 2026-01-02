#!/usr/bin/env bash
set -e

# Benötigt: yq (https://github.com/mikefarah/yq)

YML="data/projects.yml"
README="README.md"
START_MARKER="<!-- LIBRARIES START -->"
END_MARKER="<!-- LIBRARIES END -->"
TEMP_MD=".readme_libs.md"

# Hole die Projekte-Liste aus dem verschachtelten YAML
projects_path=".[0].projects"
group_count=$(yq "${projects_path} | length" "$YML")
output=""
for ((g=0; g<group_count; g++)); do
  group=$(yq -r "${projects_path}[$g].group" "$YML")
  open_flag=$(yq -r "${projects_path}[$g].open" "$YML")
  items_count=$(yq "${projects_path}[$g].items | length" "$YML")
  if [[ "$open_flag" == "true" ]]; then
    output+=$'\n<details open>\n\n'
  else
    output+=$'\n<details>\n\n'
  fi
  output+="<summary>$group ($items_count)</summary><br>\n\n"
  output+="| Libary | Description |\n| - | - |\n"
  for ((i=0; i<items_count; i++)); do
    name=$(yq -r "${projects_path}[$g].items[$i].name" "$YML")
    # Beschreibung: Für KMPParcelize den Beispieltext, sonst aus YAML
    if [[ "$name" == "KMPParcelize" ]]; then
      desc="a multiplatform parcelize implementation that supports all platforms"
    else
      desc=$(yq -r "${projects_path}[$g].items[$i].description" "$YML")
    fi
    repo_url="https://github.com/MFlisar/$name"
    if [[ "$name" == "Lumberjack" || "$name" == "ComposeChangelog" || "$name" == "ComposeDebugDrawerg" || "$name" == "ComposeDialogs" || "$name" == "ComposePreferences" || "$name" == "ComposeThemer" || "$name" == "ComposeColors" ]]; then
      repo_url+="/"
    fi
    output+="| [$name]($repo_url) | $desc |\n"
  done
  output+=$'\n'</details>\n\n'
done

echo -n "$output" > "$TEMP_MD"

# Bereich im README ersetzen (sed: alles zwischen den Markern löschen, dann neuen Inhalt einfügen)
sed -i.bak "/$START_MARKER/,/$END_MARKER/{ /$START_MARKER/{p; r $TEMP_MD
        }; /$END_MARKER/p; d }" "$README"
rm "$TEMP_MD" "$README.bak"
