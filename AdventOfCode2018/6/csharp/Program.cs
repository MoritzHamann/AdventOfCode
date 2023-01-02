using System;
using System.Linq;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace csharp {

    class Point {
        public Point(int x, int y) {
            this.x = x;
            this.y = y;
        }
        public int distance(Point p) {
            return Math.Abs(x - p.x) + Math.Abs(y - p.y);
        }
        public int x, y;
    }

    class Program {

        static Point[] FindBoundingBox(List<Point> points) {
            int? minX = null, minY = null, maxX = null, maxY = null;
            foreach (var p in points) {
                if (p.x > maxX || maxX == null) maxX = p.x;
                if (p.x < minX || minX == null) minX = p.x;
                if (p.y > maxY || maxY == null) maxY = p.y;
                if (p.y < minY || minY == null) minY = p.y;
            }
            Point[] boundingBox = {
                new Point(minX ?? -1, minY ?? -1),
                new Point(maxX ?? -1, maxY ?? -1)};
            return boundingBox;
        }

        static string Part1(List<Point> input) {
            var BB = FindBoundingBox(input);
            var AreaForPoint = new Dictionary<Point, int>();

            for (var x = BB[0].x; x < BB[1].x; x++) {
                for (var y = BB[0].y; y < BB[1].y; y++) {
                    int? minDistance = null;
                    Point closetPoint = null;
                    Point currentCoord = new Point(x, y);
                    foreach (var p in input) {
                        // terminate for same distance
                        if (minDistance != null && p.distance(currentCoord) == minDistance) {
                            closetPoint = null;
                            break;
                        }
                        if (minDistance == null || p.distance(currentCoord) < minDistance) {
                            minDistance = p.distance(currentCoord);
                            closetPoint = p;
                        }
                    }
                    if (closetPoint == null)
                        continue;
                    if (!AreaForPoint.ContainsKey(closetPoint))
                        AreaForPoint[closetPoint] = 0;
                    AreaForPoint[closetPoint]++;
                }
            }
            return AreaForPoint.Values.Max().ToString();
        }

        static string part2(List<Point> input) {
            var AreaUnderThreshold = 0;
            var BB = FindBoundingBox(input);
            for (var x = BB[0].x; x < BB[1].x; x++) {
                for (var y = BB[0].y; y < BB[1].y; y++) {
                    var currentPoint = new Point(x, y);
                    var totalDistance = input.Sum(p => p.distance(currentPoint));
                    if (totalDistance < 10000)
                        AreaUnderThreshold++;
                }
            }
            return AreaUnderThreshold.ToString();
        }

        static void Main(string[] args) {
            List<Point> input = new List<Point>();
            foreach (var line in System.IO.File.ReadLines(args[0])) {
                var m =  Regex.Match(line, @"(\d+), (\d+)");
                var t = new Point(Int32.Parse(m.Groups[1].Value), Int32.Parse(m.Groups[2].Value));
                input.Add(t);
            }

            // part 1 and 2
            Console.WriteLine(Part1(input));
            Console.WriteLine(part2(input));
        }
    }
}
