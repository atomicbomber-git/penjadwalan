<?php


namespace App\Casts;


use Illuminate\Contracts\Database\Eloquent\CastsAttributes;
use Spatie\Period\Boundaries;
use Spatie\Period\Period;
use Spatie\Period\Precision;

class TimestampRange implements CastsAttributes
{
    const BOUNDARY_MAP = [
        '[]' => Boundaries::EXCLUDE_ALL,
        '(]' => Boundaries::EXCLUDE_START,
        '[)' => Boundaries::EXCLUDE_END,
        '()' => Boundaries::EXCLUDE_NONE,
    ];

    private function determineBoundaryMarkers(Period $period): array
    {
        // Get boundary exclusion mask
        $mask = Boundaries::EXCLUDE_NONE;
        if ($period->startExcluded()) {
            $mask |= Boundaries::EXCLUDE_START;
        }

        if ($period->endExcluded()) {
            $mask |= Boundaries::EXCLUDE_END;
        }

        return str_split(array_flip(self::BOUNDARY_MAP)[$mask], 1);
    }

    /**
     * @param $start_boundary
     * @param $end_boundary
     * @return int
     * @throws \Exception
     */
    private function determineBoundaryType($start_boundary, $end_boundary): int
    {
        $boundary_string = $start_boundary . $end_boundary;

        if (!isset(self::BOUNDARY_MAP[$boundary_string])) {
            throw new \Exception("Unknown boundary type: {$boundary_string}");
        }

        return self::BOUNDARY_MAP[$boundary_string];
    }

    /**
     * @inheritDoc
     * @throws \Exception
     */
    public function get($model, string $key,  $value, array $attributes)
    {
        $boundary_type = $this->determineBoundaryType(
            substr($value, 0,1),
            substr($value, -1)
        );

        [$start, $end] = explode(",", trim($value, '[]()'));

        return Period::make(
            trim($start, '"'),
            trim($end, '"'),
            Precision::SECOND,
            $boundary_type
        );
    }

    /**
     * @inheritDoc
     * @throws \Exception
     */
    public function set($model, string $key, $value, array $attributes)
    {
        if (!$value instanceof Period) {
            throw new \Exception("\$value must be instance of " . Period::class);
        }

        [$boundary_marker_start, $boundary_marker_end] = $this->determineBoundaryMarkers($value);

        return sprintf("%s%s,%s%s",
            $boundary_marker_start,
            $value->getStart()->format("Y-m-d H:i:s"),
            $value->getEnd()->format("Y-m-d H:i:s"),
            $boundary_marker_end
        );
    }
}
