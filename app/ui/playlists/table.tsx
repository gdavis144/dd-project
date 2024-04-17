import { fetchFilteredPlaylists } from '@/app/lib/data';
import { Playlist } from '@/app/lib/definitions';
import { CheckCircleIcon, MinusCircleIcon } from '@heroicons/react/24/outline';
import Link from 'next/link';

export default async function PlaylistsTable({
  query,
  currentPage,
}: {
  query: string;
  currentPage: number;
}) {
  const playlists = await fetchFilteredPlaylists(query, currentPage);

  return (
    <div className="mt-6 flow-root">
      <div className="inline-block min-w-full align-middle">
        <div className="rounded-lg bg-gray-50 p-2 md:pt-0">
          <div className="md:hidden">
            {playlists?.map((playlist: Playlist) => (
              <div
                key={playlist.playlist_id}
                className="mb-2 w-full rounded-md bg-white p-4 hover:bg-blue-100"
              >
                <div className="flex items-center justify-between border-b pb-4">
                  <div>
                    <Link className="hover:bg-blue-100" href={`/dashboard/playlists/${playlist.playlist_id}`}>
                      <div className="mb-2 flex items-center">
                        <p>{playlist.playlist_name}</p>
                      </div>
                    </Link>

                    <p className="text-sm text-gray-500">{playlist.creator}</p>
                  </div>
                  {/* <InvoiceStatus status={invoice.status} /> */}
                </div>
                <div className="flex w-full items-center justify-between pt-4">
                  <div>
                    {/* <p className="text-xl font-medium">
                      {formatCurrency(invoice.amount)}
                    </p> */}
                    <p>{playlist.like_count}</p>
                  </div>
                  <div className="flex justify-start gap-2">
                    {playlist.is_public ? (
                      <CheckCircleIcon className="left-align w-5 text-green-600" />
                    ) : (
                      <MinusCircleIcon className="w-5 text-red-600" />
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
          <table className="hidden min-w-full text-gray-900 md:table">
            <thead className="rounded-lg text-left text-sm font-normal">
              <tr>
                <th scope="col" className="px-4 py-5 font-medium sm:pl-6">
                  Playlist Name
                </th>
                <th scope="col" className="px-3 py-5 font-medium">
                  Creator
                </th>
                <th scope="col" className="px-3 py-5 font-medium">
                  Likes
                </th>
                <th scope="col" className="px-3 py-5 font-medium">
                  Public?
                </th>
              </tr>
            </thead>
            <tbody className="bg-white">
              {playlists?.map((playlist: Playlist) => (
                <tr
                  key={playlist.playlist_id}
                  className="w-full border-b py-3 text-sm last-of-type:border-none [&:first-child>td:first-child]:rounded-tl-lg [&:first-child>td:last-child]:rounded-tr-lg [&:last-child>td:first-child]:rounded-bl-lg [&:last-child>td:last-child]:rounded-br-lg"
                >
                  <td className="whitespace-nowrap py-3 pl-6 pr-3">
                  <Link className="bg-white hover:bg-blue-100" href={`/dashboard/playlists/${playlist.playlist_id}`}>
                      <div className="mb-1 flex items-center">
                        <p>{playlist.playlist_name}</p>
                      </div>
                    </Link>
                  </td>
                  <td className="whitespace-nowrap px-3 py-3">
                    {playlist.creator}
                  </td>
                  <td className="whitespace-nowrap px-3 py-3">
                    {playlist.like_count}
                  </td>
                  <td className="whitespace-nowrap px-3 py-3 pl-6">
                    <div className="flex justify-start gap-3">
                      {playlist.is_public ? (
                        <CheckCircleIcon className="w-5 text-green-600" />
                      ) : (
                        <MinusCircleIcon className="w-5 text-red-600" />
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
