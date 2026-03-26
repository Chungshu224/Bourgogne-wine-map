import json
from pathlib import Path
from typing import Any

from pyproj import Transformer
from shapely.geometry import shape, mapping

SOURCE_BASE = Path(r"C:\Users\Chungshu\Desktop\geographie")
OUTPUT_BASE = Path(r"C:\Users\Chungshu\Desktop\教學網站製作20260220\Bourgogne Wine Learning\public\geojson\geology")

PROVINCES = ["021", "058", "069", "071", "089"]
MATERIAL_FILES = {
    "clay": "Clay-dominated 黏土為主.geojson",
    "sand": "Sand-dominated 砂為主.geojson",
    "limestone": "Limestone 石灰岩.geojson",
    "gravel": "Gravel and pebbles 礫石卵石.geojson",
    "mixed": "Mixed sediments 混合沉積物.geojson",
}

MATERIAL_STYLE = {
    "clay": {"name": "黏土為主", "fillColor": "#8d6e63", "lineColor": "#5d4037"},
    "sand": {"name": "砂為主", "fillColor": "#f4c77d", "lineColor": "#c89b52"},
    "limestone": {"name": "石灰岩", "fillColor": "#cfd8dc", "lineColor": "#90a4ae"},
    "gravel": {"name": "礫石卵石", "fillColor": "#b0bec5", "lineColor": "#78909c"},
    "mixed": {"name": "混合沉積物", "fillColor": "#d7ccc8", "lineColor": "#8d6e63"},
}

PROVINCE_NAMES = {
    "021": "Cote-d'Or",
    "058": "Nievre",
    "069": "Rhone",
    "071": "Saone-et-Loire",
    "089": "Yonne",
}

# EPSG:2154 (Lambert-93) -> EPSG:4326
TRANSFORMER = Transformer.from_crs("EPSG:2154", "EPSG:4326", always_xy=True)


def transform_coords(coords: Any) -> Any:
    if isinstance(coords, (list, tuple)) and coords:
        if isinstance(coords[0], (int, float)) and isinstance(coords[1], (int, float)):
            x, y = coords[0], coords[1]
            lon, lat = TRANSFORMER.transform(x, y)
            return [round(lon, 6), round(lat, 6)]
        return [transform_coords(c) for c in coords]
    return coords


def transform_geometry(geometry: dict[str, Any], simplify_tolerance: float = 0.0002) -> dict[str, Any]:
    transformed = {
        "type": geometry.get("type"),
        "coordinates": transform_coords(geometry.get("coordinates", [])),
    }

    try:
        shp = shape(transformed)
        if not shp.is_empty:
            shp = shp.simplify(simplify_tolerance, preserve_topology=True)
            transformed = mapping(shp)
    except Exception:
        # Keep transformed coordinates even if one geometry cannot be simplified.
        pass

    return transformed


def process_file(src_file: Path, dst_file: Path) -> int:
    with src_file.open("r", encoding="utf-8") as f:
        data = json.load(f)

    features = data.get("features", [])
    out_features = []

    for feature in features:
        geometry = feature.get("geometry")
        if not geometry:
            continue

        out_features.append(
            {
                "type": "Feature",
                "geometry": transform_geometry(geometry),
                "properties": feature.get("properties", {}),
            }
        )

    out_data = {
        "type": "FeatureCollection",
        "features": out_features,
    }

    dst_file.parent.mkdir(parents=True, exist_ok=True)
    with dst_file.open("w", encoding="utf-8") as f:
        json.dump(out_data, f, ensure_ascii=False, separators=(",", ":"))

    return len(out_features)


def main() -> None:
    index = {
        "metadata": {
            "version": "1.0.0",
            "description": "Bourgogne five-province geological materials (web optimized)",
            "projection": "EPSG:4326",
            "sourceProjection": "EPSG:2154",
        },
        "materials": [],
        "provinces": {},
    }

    for material_id, filename in MATERIAL_FILES.items():
        style = MATERIAL_STYLE[material_id]
        index["materials"].append(
            {
                "id": material_id,
                "name": style["name"],
                "fillColor": style["fillColor"],
                "lineColor": style["lineColor"],
            }
        )

    for province in PROVINCES:
        province_layers = []
        total_features = 0

        for material_id, filename in MATERIAL_FILES.items():
            src = SOURCE_BASE / province / "Geological Materials 地質材料" / filename
            out_name = f"{material_id}.geojson"
            dst = OUTPUT_BASE / "provinces" / province / out_name

            count = process_file(src, dst)
            total_features += count

            province_layers.append(
                {
                    "materialId": material_id,
                    "name": MATERIAL_STYLE[material_id]["name"],
                    "url": f"/geojson/geology/provinces/{province}/{out_name}",
                    "featureCount": count,
                }
            )

        index["provinces"][province] = {
            "name": PROVINCE_NAMES.get(province, province),
            "layers": province_layers,
            "totalFeatures": total_features,
        }

    OUTPUT_BASE.mkdir(parents=True, exist_ok=True)
    with (OUTPUT_BASE / "index.json").open("w", encoding="utf-8") as f:
        json.dump(index, f, ensure_ascii=False, indent=2)

    print("Geology import completed")


if __name__ == "__main__":
    main()
